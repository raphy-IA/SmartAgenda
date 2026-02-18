import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smart_agenda_ai/core/config/api_config.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRepository {
  final String baseUrl = ApiConfig.baseUrl; 
  final Dio _dio = Dio();

  EventRepository(dynamic unusedClient) {
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
        
        // --- ADD TIMEZONE OFFSET ---
        final offset = DateTime.now().timeZoneOffset;
        final hours = offset.inHours.abs().toString().padLeft(2, '0');
        final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
        final sign = offset.isNegative ? '-' : '+';
        options.headers['X-User-Timezone'] = 'UTC$sign$hours:$minutes';
        
        return handler.next(options);
      },
    ));
  }

  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get('$baseUrl/events/');
      final data = response.data as List<dynamic>;
      
      final List<Event> events = [];
      for (var json in data) {
        try {
          events.add(Event.fromJson(json));
        } catch (e) {
          print("⚠️ ERROR PARSING EVENT ID ${json['id']}: $e");
          print("   JSON: $json");
          // Continue to next event
        }
      }
      return events;
    } catch (e) {
      print("❌ Erreur Globale GET Events: $e");
      return [];
    }
  }

  Future<Event> createEvent(Event event, {bool ignoreConflicts = false}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/events/', 
        data: event.toJson(),
        queryParameters: {'force': ignoreConflicts},
      );
      
      if (response.data is Map && response.data['code'] == 'duplicate') {
        throw DuplicateException(message: response.data['message'] ?? "Déjà existant");
      }
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Propagation des détails du conflit (incluant les suggestions)
        throw ConflictException(
          message: e.response?.data['detail']['message'] ?? "Conflit détecté",
          suggestions: (e.response?.data['detail']['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        );
      }
      print("Erreur POST Event (Dio): $e");
      throw e;
    } catch (e) {
      if (e is DuplicateException) rethrow;
      print("Erreur POST Event (Generic): $e");
      throw e;
    }
  }

  Future<void> updateEvent(Event event, {bool force = false}) async {
    try {
      final json = event.toJson();
      json.remove('id'); // On ne met pas à jour la clé primaire
      
      await _dio.patch(
        '$baseUrl/events/${event.id}', 
        data: json,
        queryParameters: {'force': force},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(
          message: e.response?.data['detail']['message'] ?? "Conflit détecté",
          suggestions: (e.response?.data['detail']['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        );
      }
      print("Erreur PATCH Event (Dio): $e");
      throw e;
    } catch (e) {
      print("Erreur PATCH Event (Generic): $e");
      throw e;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _dio.delete('$baseUrl/events/$id');
    } catch (e) {
      print("Erreur DELETE Event: $e");
      throw e;
    }
  }
}

class DuplicateException implements Exception {
  final String message;
  DuplicateException({required this.message});
  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  final List<dynamic> suggestions;
  ConflictException({required this.message, required this.suggestions});
  
  @override
  String toString() => message;
}
