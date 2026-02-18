import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_agenda_ai/core/config/api_config.dart';
import 'package:smart_agenda_ai/features/profile/data/models/user_profile.dart';

class ProfileRepository {
  final SupabaseClient _supabase;
  final Dio _dio = Dio();

  ProfileRepository(this._supabase);

  String get baseUrl => ApiConfig.baseUrl;

  Future<Options> _getOptions() async {
    final session = _supabase.auth.currentSession;
    final token = session?.accessToken ?? "demo-token";
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  Future<UserProfile> getProfile() async {
    try {
      final options = await _getOptions();
      final response = await _dio.get("$baseUrl/profiles/", options: options);
      return UserProfile.fromJson(response.data);
    } catch (e) {
      print("Erreur Fetch Profile: $e");
      rethrow;
    }
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final options = await _getOptions();
      final response = await _dio.patch("$baseUrl/profiles/", data: data, options: options);
      return UserProfile.fromJson(response.data);
    } catch (e) {
      print("Erreur Update Profile: $e");
      rethrow;
    }
  }
}
