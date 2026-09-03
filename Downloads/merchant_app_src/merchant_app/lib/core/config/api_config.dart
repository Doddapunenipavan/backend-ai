import 'package:flutter/foundation.dart';

/// Merchant app → flextenure-merchant backend (pyaadhaar Secure QR).
///
/// Physical phone must use this PC's LAN IP (same Wi‑Fi).
/// Change [lanHost] if `ipconfig` shows a different IPv4.
class ApiConfig {
  ApiConfig._();

  static const String lanHost = '192.168.1.2';
  static const int port = 5001;

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) return 'http://localhost:$port/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Emulator: use --dart-define=API_BASE_URL=http://10.0.2.2:5001/api
        return 'http://$lanHost:$port/api';
      default:
        return 'http://localhost:$port/api';
    }
  }

  static String get aadhaarDecodeUrl => '$baseUrl/aadhaar-qr/decode';
  static String get aadhaarHealthUrl => '$baseUrl/aadhaar-qr/health';
  static String get signupUrl => '$baseUrl/auth/signup';
  static String get loginUrl => '$baseUrl/auth/login';
}
