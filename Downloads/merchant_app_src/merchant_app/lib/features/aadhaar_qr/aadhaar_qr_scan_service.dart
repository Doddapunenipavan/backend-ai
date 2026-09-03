import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

/// Scan Aadhaar Secure QR from camera still or gallery.
///
/// Secure QR is a **dense QR** (long digit string). Many PVC cards put it on the
/// **front** only — that is fine. Still photos fail when the QR is small,
/// blurry, or compressed.
class AadhaarQrScanService {
  AadhaarQrScanService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Prefer QR-only first (faster), then all formats as fallback.
  Future<String?> scanFromCameraStill() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      // Full resolution — do NOT set maxWidth/maxHeight (shrinks dense QR).
      imageQuality: 100,
      requestFullMetadata: true,
    );
    if (file == null) return null; // user cancelled
    return scanImageFile(file.path);
  }

  Future<String?> scanFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      requestFullMetadata: true,
    );
    if (file == null) return null;
    return scanImageFile(file.path);
  }

  /// Returns raw Secure QR string, or null if no code found.
  Future<String?> scanImageFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    // Pass 1: QR only
    var hit = await _scanWith(
      path,
      formats: [BarcodeFormat.qrCode],
    );
    if (hit != null) return hit;

    // Pass 2: any 2D barcode ML Kit can see
    hit = await _scanWith(
      path,
      formats: const [], // empty = all formats in ML Kit
    );
    return hit;
  }

  Future<String?> _scanWith(
    String path, {
    required List<BarcodeFormat> formats,
  }) async {
    final scanner = formats.isEmpty
        ? BarcodeScanner()
        : BarcodeScanner(formats: formats);
    try {
      final input = InputImage.fromFilePath(path);
      final codes = await scanner.processImage(input);
      return _pickBestPayload(codes);
    } finally {
      await scanner.close();
    }
  }

  /// Secure QR payload is typically a **very long digit string**.
  /// Prefer longest non-empty rawValue / displayValue.
  String? _pickBestPayload(List<Barcode> codes) {
    if (codes.isEmpty) return null;

    String? best;
    var bestScore = -1;

    for (final b in codes) {
      final candidates = <String?>[
        b.rawValue,
        b.displayValue,
      ];
      for (final c in candidates) {
        final v = c?.trim();
        if (v == null || v.isEmpty) continue;

        // Score: length + bonus if mostly digits (Secure QR style)
        var score = v.length;
        if (RegExp(r'^\d+$').hasMatch(v)) score += 10000;
        // Ignore tiny URLs / short noise
        if (v.length < 20) score -= 5000;

        if (score > bestScore) {
          bestScore = score;
          best = v;
        }
      }
    }
    return best;
  }

  Future<void> dispose() async {}
}
