import 'package:dio/dio.dart';
import '../../../events/data/models/event.dart';

class VoiceRepository {
  final Dio _dio;
  
  // VPS Production
  final String baseUrl = "http://148.230.80.83:8001/api/v1"; 

  VoiceRepository(this._dio);

  Future<Event> parseCommand(String text) async {
    try {
      // Calculer l'offset local (ex: "UTC-05:00")
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = (offset.inMinutes % 60).abs();
      final sign = hours >= 0 ? '+' : '-';
      final formattedOffset = "UTC$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";

      final response = await _dio.post('$baseUrl/voice/parse',
        data: {
            'text': text,
            'user_timezone': formattedOffset // Envoi dynamique
        },
      );
      final data = response.data;
      // L'API /parse retourne un EventCreate (sans ID).
      // Le modèle Flutter Event requiert un ID. On en génère un temporaire.
      if (data['id'] == null) {
        data['id'] = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      return Event.fromJson(data);
    } catch (e) {
      throw Exception('Failed to parse voice command: $e');
    }
  }
}
