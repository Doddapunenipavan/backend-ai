import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android Java Security SHA256withRSA — never skip.
class AadhaarSecureQrJavaBridge {
  AadhaarSecureQrJavaBridge._();

  static const _channel =
      MethodChannel('com.flextenure.merchant/aadhaar_secure_qr');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<JavaSignatureResult> verifyRawPayload(String rawPayload) async {
    if (!isSupported) {
      throw UnsupportedError(
        'Signature verification only on Android — cannot be skipped.',
      );
    }
    try {
      final raw = await _channel.invokeMethod<dynamic>(
        'verifyRawPayload',
        <String, dynamic>{'rawPayload': rawPayload},
      );
      final result =
          JavaSignatureResult.fromMap(Map<String, dynamic>.from(raw as Map));
      if (!result.isValid) throw AadhaarSignatureRejectedException(result);
      return result;
    } on PlatformException catch (e) {
      throw AadhaarSignatureRejectedException(
        JavaSignatureResult(
          isValid: false,
          rejected: true,
          algorithm: 'SHA256withRSA',
          message: e.message ?? e.code,
          signatureLength: 0,
          signedDataLength: 0,
        ),
      );
    }
  }
}

class JavaSignatureResult {
  JavaSignatureResult({
    required this.isValid,
    required this.rejected,
    required this.algorithm,
    required this.message,
    required this.signatureLength,
    required this.signedDataLength,
    this.certificateUsed,
  });

  factory JavaSignatureResult.fromMap(Map<String, dynamic> map) {
    return JavaSignatureResult(
      isValid: map['isValid'] == true,
      rejected: map['rejected'] == true || map['isValid'] != true,
      algorithm: (map['algorithm'] as String?) ?? 'SHA256withRSA',
      message: (map['message'] as String?) ?? '',
      signatureLength: (map['signatureLength'] as num?)?.toInt() ?? 0,
      signedDataLength: (map['signedDataLength'] as num?)?.toInt() ?? 0,
      certificateUsed: map['certificateUsed'] as String?,
    );
  }

  final bool isValid;
  final bool rejected;
  final String algorithm;
  final String message;
  final int signatureLength;
  final int signedDataLength;
  final String? certificateUsed;
}

class AadhaarSignatureRejectedException implements Exception {
  AadhaarSignatureRejectedException(this.result);
  final JavaSignatureResult result;
  @override
  String toString() =>
      'REJECTED: Invalid Aadhaar Secure QR. ${result.message}';
}
