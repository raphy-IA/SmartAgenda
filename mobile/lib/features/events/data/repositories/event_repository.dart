import 'package:dio/dio.dart';
import '../models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRepository {
  // En Web, localhost est accessible directement.
  // En Android Emulator, c'est 10.0.2.2.
  // Pour ce test Chrome, on utilise localhost.
  final String baseUrl = "http://148.230.80.83:8001/api/v1"; 
  final Dio _dio = Dio();

  EventRepository(dynamic unusedClient) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
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

  Future<void> createEvent(Event event) async {
    try {
      await _dio.post('$baseUrl/events/', data: event.toJson());
    } catch (e) {
      print("Erreur POST Event: $e");
      throw e;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _dio.patch('$baseUrl/events/${event.id}', data: event.toJson());
    } catch (e) {
      print("Erreur PATCH Event: $e");
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
