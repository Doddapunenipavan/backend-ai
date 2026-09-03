import 'dart:typed_data';

/// Parsed UIDAI Secure QR — trust only when [signatureValid] == true.
class AadhaarSecureQrResult {
  AadhaarSecureQrResult({
    required this.rawPayload,
    required this.fields,
    this.photoJpeg,
    this.signatureLength = 0,
    this.parseNotes = const [],
    this.signedDataBytes,
    this.signatureBytes,
    this.signatureValid,
    this.signatureMessage,
    this.signatureCertificate,
    this.wasCompressed = false,
    this.compressionType = 'none',
  });

  final String rawPayload;
  final AadhaarQrFields fields;
  final Uint8List? photoJpeg;
  final int signatureLength;
  final List<String> parseNotes;
  final Uint8List? signedDataBytes;
  final Uint8List? signatureBytes;
  final bool? signatureValid;
  final String? signatureMessage;
  final String? signatureCertificate;
  final bool wasCompressed;
  final String compressionType;

  bool get isCryptographicallyAccepted => signatureValid == true;

  AadhaarSecureQrResult copyWith({
    bool? signatureValid,
    String? signatureMessage,
    String? signatureCertificate,
  }) {
    return AadhaarSecureQrResult(
      rawPayload: rawPayload,
      fields: fields,
      photoJpeg: photoJpeg,
      signatureLength: signatureLength,
      parseNotes: parseNotes,
      signedDataBytes: signedDataBytes,
      signatureBytes: signatureBytes,
      signatureValid: signatureValid ?? this.signatureValid,
      signatureMessage: signatureMessage ?? this.signatureMessage,
      signatureCertificate: signatureCertificate ?? this.signatureCertificate,
      wasCompressed: wasCompressed,
      compressionType: compressionType,
    );
  }
}

class AadhaarQrFields {
  AadhaarQrFields({
    this.name,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.careOf,
    this.district,
    this.landmark,
    this.house,
    this.location,
    this.pincode,
    this.postOffice,
    this.state,
    this.street,
    this.subDistrict,
    this.vtc,
    this.fullAddress,
    this.referenceId,
    this.last4Digits,
    this.maskedAadhaar,
    this.emailPresent = false,
    this.mobilePresent = false,
    this.emailHashHex,
    this.mobileHashHex,
    this.photoPresent = false,
    this.photoByteLength = 0,
  });

  final String? name;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? careOf;
  final String? district;
  final String? landmark;
  final String? house;
  final String? location;
  final String? pincode;
  final String? postOffice;
  final String? state;
  final String? street;
  final String? subDistrict;
  final String? vtc;
  final String? fullAddress;
  final String? referenceId;
  final String? last4Digits;
  final String? maskedAadhaar;
  final bool emailPresent;
  final bool mobilePresent;
  final String? emailHashHex;
  final String? mobileHashHex;
  final bool photoPresent;
  final int photoByteLength;

  List<MapEntry<String, String>> get displayEntries {
    final out = <MapEntry<String, String>>[];
    void add(String k, String? v) {
      if (v != null && v.trim().isNotEmpty) out.add(MapEntry(k, v.trim()));
    }

    add('Name', name);
    add('Date of Birth', dateOfBirth);
    if (age != null) add('Age', '$age years');
    add('Gender', gender);
    add('Aadhaar Number', maskedAadhaar);
    add('Care of', careOf);
    add('House', house);
    add('Street', street);
    add('Landmark', landmark);
    add('Locality', location);
    add('VTC', vtc);
    add('Sub-district', subDistrict);
    add('District', district);
    add('State', state);
    add('Pin Code', pincode);
    add('Post office', postOffice);
    add('Address', fullAddress);
    add('Reference ID', referenceId);
    add('Email', emailPresent ? 'Present (hash only)' : 'Not present');
    add('Mobile', mobilePresent ? 'Present (hash only)' : 'Not present');
    add('Photo', photoPresent ? 'Yes ($photoByteLength bytes)' : 'No');
    return out;
  }
}

class AadhaarQrDecodeException implements Exception {
  AadhaarQrDecodeException(this.message);
  final String message;
  @override
  String toString() => message;
}
