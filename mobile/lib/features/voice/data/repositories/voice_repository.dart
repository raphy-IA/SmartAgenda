import 'package:dio/dio.dart';
import '../../../events/data/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/api_config.dart';

class VoiceRepository {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl; 

  VoiceRepository(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (ApiConfig.isDemoMode) {
          options.headers['Authorization'] = 'Bearer demo-token';
        } else {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }
        return handler.next(options);
      },
    ));
  }

  Future<Event> parseCommand(String text, {required String language}) async {
    try {
      // Calcul du décalage exact (ex: "+01:00")
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours.abs().toString().padLeft(2, '0');
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final sign = offset.isNegative ? '-' : '+';
      final formattedOffset = "UTC$sign$hours:$minutes";

      // ISO8601 avec Offset (Crucial pour l'IA)
      final localIso = "${now.toIso8601String().split('.')[0]}$sign$hours:$minutes";

      final response = await _dio.post('$baseUrl/voice/parse',
        data: {
            'text': text,
            'user_timezone': formattedOffset, 
            'local_time': localIso,
            'language': language, // AUTO, FR ou EN
        },
      );
      final data = response.data;
      // L'API /parse retourne un EventCreate (sans ID).
      // Le modèle Flutter Event requiert un ID. On en génère un temporaire.
      if (data['id'] == null) {
        data['id'] = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      final event = Event.fromJson(data);
      return event;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
          // Si le parsing a fonctionné mais que le backend a détecté un conflit pendant le process interm (rare ici car /parse ne crée pas)
          // Mais au cas où le repository d'event est appelé par l'user après.
      }
      rethrow;
    }
  }
}
