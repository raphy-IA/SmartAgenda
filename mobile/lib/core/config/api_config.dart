import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static bool isDemoMode = false;

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8001/api/v1";
    }
    // Android Emulator IP
    return "http://10.0.2.2:8001/api/v1";
  }
}
