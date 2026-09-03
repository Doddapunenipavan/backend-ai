import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// HTTP client for merchant backend (Aadhaar pyaadhaar image decode).
class MerchantApiService {
  MerchantApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _tokenKey = 'merchant_api_token';
  static const _timeout = Duration(seconds: 45);

  Future<String?> readToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
  }

  /// Ensure we have a JWT for Bearer routes (auto signup/login once).
  Future<String> ensureAuthToken() async {
    final existing = await readToken();
    if (existing != null && existing.isNotEmpty) return existing;

    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('auth_email');
    if (email == null || email.isEmpty) {
      final phone = prefs.getString('auth_phone') ?? '';
      final id = phone.isNotEmpty
          ? phone
          : DateTime.now().millisecondsSinceEpoch.toString();
      email = 'merchant_$id@flextenure.local';
      await prefs.setString('auth_email', email);
    }
    const password = 'FlexMerchant@12345';

    // Try login first
    try {
      final loginRes = await _client
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
      if (loginRes.statusCode >= 200 && loginRes.statusCode < 300) {
        final token = _extractToken(loginRes.body);
        if (token != null) {
          await saveToken(token);
          return token;
        }
      }
    } catch (_) {
      /* try signup */
    }

    final signupRes = await _client
        .post(
          Uri.parse(ApiConfig.signupUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': 'Merchant App User',
            'email': email,
            'password': password,
            'phone': prefs.getString('auth_phone'),
          }),
        )
        .timeout(_timeout);

    if (signupRes.statusCode >= 200 && signupRes.statusCode < 300) {
      final token = _extractToken(signupRes.body);
      if (token != null) {
        await saveToken(token);
        return token;
      }
    }

    // Login after race (email exists)
    final login2 = await _client
        .post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);
    final token = _extractToken(login2.body);
    if (token == null) {
      throw MerchantApiException(
        'Cannot authenticate with merchant backend. '
        'Is API running at ${ApiConfig.baseUrl}? '
        '(${login2.statusCode}) ${login2.body}',
      );
    }
    await saveToken(token);
    return token;
  }

  String? _extractToken(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['token'] as String? ??
          (map['data'] is Map
              ? (map['data'] as Map)['token'] as String?
              : null);
    } catch (_) {
      return null;
    }
  }

  /// Pyaadhaar path: upload Aadhaar image → decode Secure QR on server.
  Future<Map<String, dynamic>> decodeAadhaarImage(File imageFile) async {
    final token = await ensureAuthToken();
    final uri = Uri.parse(ApiConfig.aadhaarDecodeUrl);
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['store'] = 'true';
    req.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw MerchantApiException(
        'Invalid server response (${res.statusCode}). Is backend running?',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MerchantApiException(
        body['error']?.toString() ??
            body['message']?.toString() ??
            'Decode failed (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }
    return body;
  }

  Future<Map<String, dynamic>> health() async {
    final res = await _client
        .get(Uri.parse(ApiConfig.aadhaarHealthUrl))
        .timeout(const Duration(seconds: 8));
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw MerchantApiException('Health check failed (${res.statusCode})');
    }
  }
}

class MerchantApiException implements Exception {
  MerchantApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
