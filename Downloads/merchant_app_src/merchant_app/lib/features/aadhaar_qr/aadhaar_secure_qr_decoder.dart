import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'aadhaar_secure_qr_models.dart';

/// Offline UIDAI Secure QR decode (merchant app). Signature verify is separate.
class AadhaarSecureQrDecoder {
  AadhaarSecureQrDecoder._();

  static const int _sep = 0xff;
  static const int _sigLen = 256;

  static AadhaarSecureQrResult decode(String rawPayload) {
    final notes = <String>[];
    final cleaned = rawPayload.trim();
    if (cleaned.isEmpty) throw AadhaarQrDecodeException('Empty QR payload');

    final rawBytes = _payloadToBytes(cleaned, notes);
    notes.add('Raw bytes: ${rawBytes.length}');

    var sigLen = _sigLen;
    if (rawBytes.length <= sigLen + 16) {
      sigLen = 0;
      notes.add('Payload too short for 256-byte signature');
    }

    final dataBytes = sigLen > 0
        ? Uint8List.sublistView(rawBytes, 0, rawBytes.length - sigLen)
        : rawBytes;
    final signatureBytes = sigLen > 0
        ? Uint8List.sublistView(rawBytes, rawBytes.length - sigLen)
        : Uint8List(0);

    final decomp = _autoDecompress(dataBytes, notes);
    final parsed = _parseFields(decomp.bytes, notes);

    return AadhaarSecureQrResult(
      rawPayload: cleaned,
      fields: parsed.fields,
      photoJpeg: parsed.photo,
      signatureLength: signatureBytes.length,
      parseNotes: notes,
      signedDataBytes: Uint8List.fromList(dataBytes),
      signatureBytes: signatureBytes.isEmpty
          ? null
          : Uint8List.fromList(signatureBytes),
      wasCompressed: decomp.wasCompressed,
      compressionType: decomp.type,
    );
  }

  static Uint8List _payloadToBytes(String payload, List<String> notes) {
    if (RegExp(r'^\d+$').hasMatch(payload)) {
      notes.add('Format: base-10 Secure QR');
      var hex = BigInt.parse(payload).toRadixString(16);
      if (hex.length.isOdd) hex = '0$hex';
      return _hexToBytes(hex);
    }
    final hex = payload.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex) && hex.length.isEven) {
      notes.add('Format: hex');
      return _hexToBytes(hex);
    }
    try {
      final n = payload.replaceAll('-', '+').replaceAll('_', '/');
      final pad = n.length % 4 == 0
          ? n
          : n.padRight(n.length + (4 - n.length % 4), '=');
      notes.add('Format: base64');
      return Uint8List.fromList(base64.decode(pad));
    } catch (_) {}
    notes.add('Format: latin1 bytes');
    return Uint8List.fromList(payload.codeUnits);
  }

  static Uint8List _hexToBytes(String hex) {
    final out = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      out[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return out;
  }

  static _Decomp _autoDecompress(Uint8List data, List<String> notes) {
    if (data.length > 2 && data[0] == 0x1f && data[1] == 0x8b) {
      try {
        final out = GZipDecoder().decodeBytes(data, verify: false);
        notes.add('GZIP decompressed');
        return _Decomp(Uint8List.fromList(out), true, 'gzip');
      } catch (_) {}
    }
    if (data.length > 2 && data[0] == 0x78) {
      try {
        final out = const ZLibDecoder().decodeBytes(data, verify: false);
        notes.add('ZLIB decompressed');
        return _Decomp(Uint8List.fromList(out), true, 'zlib');
      } catch (_) {}
    }
    try {
      final out = const ZLibDecoder().decodeBytes(data, verify: false);
      if (out.length > data.length) {
        notes.add('DEFLATE decompressed');
        return _Decomp(Uint8List.fromList(out), true, 'deflate');
      }
    } catch (_) {}
    notes.add('No compression');
    return _Decomp(data, false, 'none');
  }

  static _Parsed _parseFields(Uint8List content, List<String> notes) {
    Uint8List? photo;
    var demoEnd = content.length;
    final js = _indexJpeg(content);
    if (js >= 0) {
      final je = _indexJpegEnd(content, js);
      if (je > js) {
        photo = Uint8List.fromList(content.sublist(js, je));
        demoEnd = js;
        notes.add('Photo JPEG: ${photo.length} bytes');
      }
    }

    final parts = _split255(Uint8List.sublistView(content, 0, demoEnd));
    var idx = 0;
    int? indicator;
    if (parts.isNotEmpty) {
      final first = _utf8(parts[0]);
      final n = int.tryParse(first ?? '');
      if (n != null && n >= 0 && n <= 3) {
        indicator = n;
        idx = 1;
      }
    }
    final emailPresent = indicator == 1 || indicator == 3;
    final mobilePresent = indicator == 2 || indicator == 3;
    String? emailHash;
    String? mobileHash;
    if (emailPresent && idx < parts.length && parts[idx].length == 32) {
      emailHash = _toHex(parts[idx]);
      idx++;
    }
    if (mobilePresent && idx < parts.length && parts[idx].length == 32) {
      mobileHash = _toHex(parts[idx]);
      idx++;
    }

    final texts = <String>[];
    for (var i = idx; i < parts.length; i++) {
      texts.add(_utf8(parts[i]) ?? '');
    }
    String? w(int i) {
      if (i >= texts.length) return null;
      final t = texts[i].trim();
      return t.isEmpty ? null : t;
    }

    final referenceId = w(0);
    final name = w(1);
    final dob = w(2);
    final genderRaw = w(3);
    final careOf = w(4);
    final district = w(5);
    final landmark = w(6);
    final house = w(7);
    final location = w(8);
    final pincode = w(9);
    final postOffice = w(10);
    final state = w(11);
    final street = w(12);
    final subDistrict = w(13);
    final vtc = w(14);

    String? last4;
    if (referenceId != null && referenceId.length >= 4) {
      final m = RegExp(r'(\d{4})$').firstMatch(referenceId);
      if (m != null) last4 = m.group(1);
    }

    final gender = _normGender(genderRaw);
    final age = _ageFromDob(dob);

    final addr = [
      if (careOf != null) careOf,
      if (house != null) house,
      if (street != null) street,
      if (landmark != null) landmark,
      if (location != null) location,
      if (vtc != null) vtc,
      if (subDistrict != null) subDistrict,
      if (district != null) district,
      if (state != null) state,
      if (pincode != null) pincode,
      if (postOffice != null) 'PO: $postOffice',
    ];

    return _Parsed(
      AadhaarQrFields(
        name: name,
        dateOfBirth: dob,
        age: age,
        gender: gender,
        careOf: careOf,
        district: district,
        landmark: landmark,
        house: house,
        location: location,
        pincode: pincode,
        postOffice: postOffice,
        state: state,
        street: street,
        subDistrict: subDistrict,
        vtc: vtc,
        fullAddress: addr.isEmpty ? null : addr.join(', '),
        referenceId: referenceId,
        last4Digits: last4,
        maskedAadhaar: last4 != null ? 'XXXX-XXXX-$last4' : null,
        emailPresent: emailPresent,
        mobilePresent: mobilePresent,
        emailHashHex: emailHash,
        mobileHashHex: mobileHash,
        photoPresent: photo != null && photo.isNotEmpty,
        photoByteLength: photo?.length ?? 0,
      ),
      photo,
    );
  }

  static String? _normGender(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final u = raw.trim().toUpperCase();
    if (u == 'M' || u == 'MALE') return 'Male';
    if (u == 'F' || u == 'FEMALE') return 'Female';
    if (u == 'T' || u == 'TRANSGENDER' || u == 'TRANS') return 'Transgender';
    return raw.trim();
  }

  static int? _ageFromDob(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    var m = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(s);
    DateTime? d;
    if (m != null) {
      d = DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!),
          int.parse(m.group(1)!));
    } else {
      m = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$').firstMatch(s);
      if (m != null) {
        d = DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!),
            int.parse(m.group(3)!));
      }
    }
    if (d == null) return null;
    final now = DateTime.now();
    var years = now.year - d.year;
    if (now.month < d.month ||
        (now.month == d.month && now.day < d.day)) {
      years--;
    }
    if (years < 0 || years > 150) return null;
    return years;
  }

  static List<Uint8List> _split255(Uint8List data) {
    final parts = <Uint8List>[];
    var start = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i] == _sep) {
        parts.add(i > start
            ? Uint8List.sublistView(data, start, i)
            : Uint8List(0));
        start = i + 1;
      }
    }
    if (start < data.length) {
      parts.add(Uint8List.sublistView(data, start));
    }
    return parts;
  }

  static int _indexJpeg(Uint8List data) {
    for (var i = 0; i < data.length - 1; i++) {
      if (data[i] == 0xff && data[i + 1] == 0xd8) return i;
    }
    return -1;
  }

  static int _indexJpegEnd(Uint8List data, int start) {
    for (var i = start + 2; i < data.length - 1; i++) {
      if (data[i] == 0xff && data[i + 1] == 0xd9) return i + 2;
    }
    return data.length;
  }

  static String? _utf8(Uint8List bytes) {
    if (bytes.isEmpty) return '';
    try {
      return utf8.decode(bytes, allowMalformed: true).trim();
    } catch (_) {
      return latin1.decode(bytes).trim();
    }
  }

  static String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}

class _Decomp {
  _Decomp(this.bytes, this.wasCompressed, this.type);
  final Uint8List bytes;
  final bool wasCompressed;
  final String type;
}

class _Parsed {
  _Parsed(this.fields, this.photo);
  final AadhaarQrFields fields;
  final Uint8List? photo;
}
