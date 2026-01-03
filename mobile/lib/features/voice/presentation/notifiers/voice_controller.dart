import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../events/presentation/providers/event_providers.dart';
import '../../data/repositories/voice_repository.dart';
import 'package:dio/dio.dart';

// État de l'interaction vocale
class VoiceState {
  final bool isListening;
  final bool isProcessing;
  final String text; // Texte reconnu
  final String? error;

  VoiceState({
    this.isListening = false,
    this.isProcessing = false,
    this.text = '',
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isProcessing,
    String? text,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      text: text ?? this.text,
      error: error ?? this.error,
    );
  }
}

// Provider du Repository
final voiceRepositoryProvider = Provider((ref) => VoiceRepository(Dio()));

// Controller (Notifier)
class VoiceController extends StateNotifier<VoiceState> {
  final SpeechToText _speechToText = SpeechToText();
  final VoiceRepository _repository;
  final Ref _ref;

  VoiceController(this._repository, this._ref) : super(VoiceState());

  Future<void> initSpeech() async {
    bool available = await _speechToText.initialize(
      onError: (val) => state = state.copyWith(isListening: false, error: val.errorMsg),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          state = state.copyWith(isListening: false);
        }
      },
    );
    if (!available) {
      state = state.copyWith(error: "Reconnaissance vocale non disponible");
    }
  }

  Future<void> startListening() async {
    state = state.copyWith(isListening: true, error: null, text: '');
    await _speechToText.listen(
      onResult: (result) {
        state = state.copyWith(text: result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(cancelOnError: true, partialResults: true),
    );
  }

  // STOP & SEND
  Future<void> stopAndSend() async {
    await _speechToText.stop();
    state = state.copyWith(isListening: false);
    
    if (state.text.isNotEmpty) {
      final capturedText = state.text;
      await _processCommand(capturedText);
      // Double sécurité : on vide le texte après traitement
      state = state.copyWith(text: '');
    } else {
      state = state.copyWith(error: "Je n'ai rien entendu.");
    }
  }

  // CANCEL (Reset)
  Future<void> cancelRecording() async {
    await _speechToText.cancel();
    state = state.copyWith(isListening: false, text: '');
  }
  
  Future<void> _processCommand(String text) async {
    if (state.isProcessing) return; // FIX: Prevent double submission
    
    state = state.copyWith(isProcessing: true);
    try {
      final event = await _repository.parseCommand(text);
      
      // CHECK REFUS IA (HORS SUJET)
      if (event.status == 'cancelled' && event.title == 'ERREUR') {
         final errorMsg = event.metadata?['error_message'] ?? "Commande refusée.";
         state = state.copyWith(isProcessing: false, error: errorMsg);
         return;
      }

      // Ajouter l'événement au repository d'Events local (via provider)
      final eventRepo = _ref.read(eventRepositoryProvider);
      await eventRepo.createEvent(event);
      
      // Rafraichir la liste
      _ref.refresh(eventsProvider);
      
      state = state.copyWith(isProcessing: false, text: '');
      state = state.copyWith(isProcessing: false, text: '');
    } catch (e) {
      String errorMessage = "Une erreur est survenue.";
      
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          // Conflit détecté
          errorMessage = "Conflit ! Vous avez déjà un rendez-vous à cette heure-là.";
        } else if (e.response?.statusCode == 500) {
           errorMessage = "Erreur serveur. Réessayez.";
        } else {
           errorMessage = "Erreur réseau: ${e.message}";
        }
      } else {
        errorMessage = e.toString();
      }

      state = state.copyWith(isProcessing: false, error: errorMessage);
    }
  }
}

final voiceControllerProvider = StateNotifierProvider<VoiceController, VoiceState>((ref) {
  final repo = ref.watch(voiceRepositoryProvider);
  final controller = VoiceController(repo, ref);
  controller.initSpeech(); // Init au démarrage (lazy)
  return controller;
});
