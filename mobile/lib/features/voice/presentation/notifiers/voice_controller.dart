import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:smart_agenda_ai/features/events/data/repositories/event_repository.dart';
import '../../../events/presentation/providers/event_providers.dart';
import '../../data/repositories/voice_repository.dart';
import 'package:dio/dio.dart';

// Modes de langue pour la voix
enum VoiceLanguageMode { auto, fr, en }

// État de l'interaction vocale
class VoiceState {
  final bool isListening;
  final bool isProcessing;
  final String text; // Texte reconnu
  final String? error;
  final String? localeId; // ID effectif envoyé au moteur (ex: "fr-FR")
  final VoiceLanguageMode mode; // Mode sélectionné (AUTO, FR, EN)
  final ConflictException? conflict; 
  final Event? pendingEvent; 
  final String? systemLocaleId; // Stocker la locale système détectée

  VoiceState({
    this.isListening = false,
    this.isProcessing = false,
    this.text = '',
    this.error,
    this.localeId,
    this.mode = VoiceLanguageMode.auto,
    this.conflict,
    this.pendingEvent,
    this.systemLocaleId,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isProcessing,
    String? text,
    String? error,
    bool clearLocale = false,
    String? localeId,
    VoiceLanguageMode? mode,
    ConflictException? conflict,
    Event? pendingEvent,
    bool clearConflict = false,
    String? systemLocaleId,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      text: text ?? this.text,
      error: error ?? this.error,
      localeId: clearLocale ? null : (localeId ?? this.localeId),
      mode: mode ?? this.mode,
      conflict: clearConflict ? null : (conflict ?? this.conflict),
      pendingEvent: clearConflict ? null : (pendingEvent ?? this.pendingEvent),
      systemLocaleId: systemLocaleId ?? this.systemLocaleId,
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
      onError: (val) {
        String userError = val.errorMsg;
        if (val.errorMsg == "error_no_match") {
          userError = "Je n'ai pas compris. Parlez plus distinctement ou vérifiez votre connexion.";
        } else if (val.errorMsg == "error_audio_error") {
          userError = "Erreur audio. Vérifiez les permissions du micro.";
        }
        state = state.copyWith(isListening: false, error: userError);
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          state = state.copyWith(isListening: false);
        }
      },
    );
    
    if (available) {
      // Log des locales pour debug
      final locales = await _speechToText.locales();
      if (kDebugMode) {
        print("🌍 Locales disponibles :");
        for (var l in locales) {
          print("  - ${l.localeId} (${l.name})");
        }
      }
      
      // Pour AUTO, on laisse localeId à null pour laisser le système gérer
      final system = await _speechToText.systemLocale();
      state = state.copyWith(
        mode: VoiceLanguageMode.auto, 
        clearLocale: true,
        systemLocaleId: system?.localeId,
      );
    } else {
      state = state.copyWith(error: "Reconnaissance vocale non disponible");
    }
  }

  // TOGGLE LANGUAGE (AUTO -> FR -> EN)
  Future<void> toggleLanguage() async {
    final nextMode = switch (state.mode) {
      VoiceLanguageMode.auto => VoiceLanguageMode.fr,
      VoiceLanguageMode.fr => VoiceLanguageMode.en,
      VoiceLanguageMode.en => VoiceLanguageMode.auto,
    };

    if (nextMode == VoiceLanguageMode.auto) {
      // Mode AUTO : Pas de localeId forcée, et on efface l'erreur
      state = state.copyWith(mode: nextMode, clearLocale: true, error: null);
    } else {
      final locales = await _speechToText.locales();
      final targetPrefix = nextMode == VoiceLanguageMode.fr ? "fr" : "en";
      
      // PRIORITÉ 1: Si la locale système correspond à la langue demandée, on utilise NULL
      // pour laisser le moteur utiliser son réglage par défaut (on SAIT que ça marche en AUTO)
      if (state.systemLocaleId != null && state.systemLocaleId!.toLowerCase().startsWith(targetPrefix)) {
        state = state.copyWith(mode: nextMode, clearLocale: true, error: null);
        return;
      }

      LocaleName bestMatch;
      try {
        bestMatch = locales.firstWhere(
          (l) => l.localeId.toLowerCase().replaceAll("_", "-") == (nextMode == VoiceLanguageMode.fr ? "fr-fr" : "en-us")
        );
      } catch (_) {
        try {
          bestMatch = locales.firstWhere((l) => l.localeId.toLowerCase().startsWith(targetPrefix));
        } catch (_) {
          try {
            bestMatch = locales.firstWhere((l) => l.localeId.contains(targetPrefix));
          } catch (_) {
            bestMatch = nextMode == VoiceLanguageMode.fr 
              ? LocaleName("fr-FR", "Français") 
              : LocaleName("en-US", "English");
          }
        }
      }
      state = state.copyWith(mode: nextMode, localeId: bestMatch.localeId, error: null);
    }
  }

  Future<void> startListening() async {
    state = state.copyWith(isListening: true, error: null, text: '', clearConflict: true);
    
    // Log pour debug
    if (kDebugMode) print("🎙️ Listening with locale: ${state.localeId}");

    await _speechToText.listen(
      onResult: (result) {
        if (kDebugMode) print("🎙️ onResult: ${result.recognizedWords} (final: ${result.finalResult})");
        state = state.copyWith(text: result.recognizedWords);
      },
      localeId: state.localeId, 
      listenOptions: SpeechListenOptions(
        cancelOnError: true, 
        partialResults: true,
      ),
    );
  }

  // STOP (Just stops listening, allows user to verify before sending)
  Future<void> stopListening() async {
    await _speechToText.stop();
    state = state.copyWith(isListening: false);
  }

  // SUBMIT (Called after listening stops automatically)
  Future<void> submitCapturedText() async {
    if (state.text.isNotEmpty) {
      final capturedText = state.text;
      await _processCommand(capturedText);
      // Double sécurité : on vide le texte après traitement
      state = state.copyWith(text: '');
    } else {
      // On n'affiche pas d'erreur si c'était juste un silence, sauf si c'est explicite
      if (state.error == null) {
        state = state.copyWith(error: "Je n'ai rien entendu.");
      }
    }
  }

  // CANCEL (Reset)
  Future<void> cancelRecording() async {
    await _speechToText.cancel();
    state = state.copyWith(isListening: false, text: '', error: null, clearConflict: true);
  }

  void clearConflict() {
    state = state.copyWith(clearConflict: true);
  }

  Future<void> forceCreateAfterConflict() async {
    if (state.pendingEvent == null) return;
    final event = state.pendingEvent!;
    state = state.copyWith(isProcessing: true, clearConflict: true);
    try {
      final eventRepo = _ref.read(eventRepositoryProvider);
      await eventRepo.createEvent(event, ignoreConflicts: true);
      _ref.refresh(eventsProvider);
      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  Future<void> resolveWithSuggestion(Map<String, dynamic> suggestion) async {
    if (state.pendingEvent == null) return;
    
    final newStart = DateTime.parse(suggestion['start_time']).toLocal();
    final newEnd = DateTime.parse(suggestion['end_time']).toLocal();
    
    final resolvedEvent = Event(
      id: state.pendingEvent!.id,
      title: state.pendingEvent!.title,
      startTime: newStart,
      endTime: newEnd,
      location: state.pendingEvent!.location,
      status: state.pendingEvent!.status,
      categoryId: state.pendingEvent!.categoryId,
      metadata: Map.from(state.pendingEvent!.metadata ?? {}),
    );

    state = state.copyWith(isProcessing: true, clearConflict: true);
    try {
      final eventRepo = _ref.read(eventRepositoryProvider);
      await eventRepo.createEvent(resolvedEvent);
      _ref.refresh(eventsProvider);
      // SUCCESS: Clear everything
      state = state.copyWith(isProcessing: false, text: '', clearConflict: true);
    } catch (e) {
      if (e is ConflictException) {
        state = state.copyWith(isProcessing: false, conflict: e, pendingEvent: resolvedEvent);
      } else {
        state = state.copyWith(isProcessing: false, error: e.toString());
      }
    }
  }
  
  Future<void> _processCommand(String text) async {
    if (kDebugMode) print("🚀 _processCommand called for text: $text");
    if (state.isProcessing) return; // FIX: Prevent double submission
    
    state = state.copyWith(isProcessing: true, clearConflict: true);
    Event? currentEvent;
    try {
      currentEvent = await _repository.parseCommand(text, language: state.mode.name);
      
      // CHECK REFUS IA (HORS SUJET)
      if (currentEvent.status == 'cancelled' && currentEvent.title == 'ERREUR') {
         final errorMsg = currentEvent.metadata?['error_message'] ?? "Commande refusée.";
         state = state.copyWith(isProcessing: false, error: errorMsg, text: '');
         return;
      }

      // Ajouter l'événement au repository d'Events local (via provider)
      final eventRepo = _ref.read(eventRepositoryProvider);
      await eventRepo.createEvent(currentEvent);
      
      // Rafraichir la liste
      _ref.refresh(eventsProvider);
      
      state = state.copyWith(isProcessing: false, text: '');
    } catch (e) {
      if (e is ConflictException) {
        // ON STOCKE LE CONFLIT ET L'EVENT QUI L'A CAUSÉ, ET ON VIDE LE TEXTE
        state = state.copyWith(
          isProcessing: false, 
          conflict: e, 
          pendingEvent: currentEvent,
          text: '', // Important: vider le texte pour cacher les boutons Valider/Annuler
        ); 
      } else if (e is DuplicateException) {
         state = state.copyWith(isProcessing: false, error: "Cet événement existe déjà.", text: '');
      } else if (e is DioException) {
         final detail = e.response?.data?['detail'] ?? e.message;
         if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
            state = state.copyWith(isProcessing: false, error: "Délai d'attente dépassé. Vérifiez votre connexion.");
         } else if (e.response?.statusCode == 500) {
            state = state.copyWith(isProcessing: false, error: "Erreur serveur (500): $detail");
         } else {
            state = state.copyWith(isProcessing: false, error: "Erreur réseau (${e.response?.statusCode ?? '??'}): $detail");
         }
      } else {
        state = state.copyWith(isProcessing: false, error: "Erreur: ${e.toString()}");
      }
    }
  }
}

final voiceControllerProvider = StateNotifierProvider<VoiceController, VoiceState>((ref) {
  final repo = ref.watch(voiceRepositoryProvider);
  final controller = VoiceController(repo, ref);
  controller.initSpeech(); // Init au démarrage (lazy)
  return controller;
});
