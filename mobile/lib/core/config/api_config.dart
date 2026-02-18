import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, kDebugMode;

class ApiConfig {
  static bool isDemoMode = false;

  // IP pour le développement local (Emulateur: 10.0.2.2, Physique: IP de votre PC)
  static const String localNetworkIp = "10.0.2.2"; 

  // ADRESSE DE VOTRE VPS EN PRODUCTION (IPv4 est plus fiable)
  static const String vpsUrl = "148.230.80.83"; 

  static String get baseUrl {
    // En mode RELEASE (APK final), on utilise le VPS sur le port 8001
    if (kReleaseMode) {
      return "http://$vpsUrl:8001/api/v1";
    }

    // En mode DEBUG (Chrome/Émulateur)
    if (kIsWeb) {
      return "http://localhost:8001/api/v1";
    }
    return "http://$localNetworkIp:8001/api/v1";
  }
}
