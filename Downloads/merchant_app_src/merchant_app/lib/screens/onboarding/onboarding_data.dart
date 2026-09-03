class OnboardingData {
  // Step 1 — Auth
  String phone = '';
  String email = '';
  bool authenticated = false;

  // Step 2 — Business details
  String businessName = '';
  String businessType = '';
  String industry = '';
  String gstin = '';
  String pan = '';
  String cin = '';
  String yearIncorporation = '';
  String businessEmail = '';
  String businessPhone = '';
  String address = '';
  String city = '';
  String state = '';
  String pincode = '';
  String country = 'India';

  // Step 3 — Documents (real file uploads)
  final Map<String, UploadedDoc?> documents = {
    'GST Certificate': null,
    'PAN Card': null,
    'Aadhaar Card': null,
    'Business Registration': null,
  };
  bool get allDocumentsUploaded => documents.values.every((v) => v != null);

  // Step 4 — KYC
  String kycType = '';
  bool kycVerified = false;

  // Step 5 — Bank
  String selectedBank = '';
  bool bankLinked = false;

  // Step 6 — Agreement
  bool signed = false;

  // Step 7 — Approval
  String approvalStatus = 'approved';
  final String merchantId =
      'FLX-MRC-${20240000 + (DateTime.now().millisecondsSinceEpoch % 10000)}';
}

/// Holds metadata about an uploaded file.
class UploadedDoc {
  UploadedDoc({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.extension,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String extension;

  String get sizeReadable {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
