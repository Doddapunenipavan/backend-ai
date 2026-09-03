import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/config/api_config.dart';
import '../../core/services/merchant_api_service.dart';
import '../onboarding/onboarding_theme.dart';

/// Merchant KYC — Aadhaar Secure QR via **backend pyaadhaar** pipeline.
///
/// Flow: Camera/Gallery photo → multipart POST /api/aadhaar-qr/decode
/// (sharp + jsQR + zlib + SHA256withRSA). Not local ML Kit only.
class AadhaarSecureQrScreen extends StatefulWidget {
  const AadhaarSecureQrScreen({super.key});

  @override
  State<AadhaarSecureQrScreen> createState() => _AadhaarSecureQrScreenState();
}

class _AadhaarSecureQrScreenState extends State<AadhaarSecureQrScreen> {
  final _api = MerchantApiService();
  final _picker = ImagePicker();

  var _busy = false;
  String? _error;
  String? _status;
  Map<String, dynamic>? _result;
  Uint8List? _photoBytes;

  Future<void> _pickAndUpload(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _photoBytes = null;
      _status = 'Opening camera/gallery…';
    });
    try {
      if (source == ImageSource.camera) {
        final cam = await Permission.camera.request();
        if (!cam.isGranted) {
          setState(() => _error = 'Camera permission required');
          return;
        }
      }

      final file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
        requestFullMetadata: true,
      );
      if (file == null) {
        setState(() => _error = 'No photo selected.');
        return;
      }

      setState(() => _status = 'Connecting to pyaadhaar backend…');
      await _api.ensureAuthToken();

      setState(
        () => _status =
            'Uploading image to ${ApiConfig.baseUrl} (Secure QR decode)…',
      );
      final data = await _api.decodeAadhaarImage(File(file.path));

      Uint8List? photo;
      final b64 = data['photo']?.toString();
      if (b64 != null && b64.isNotEmpty) {
        try {
          photo = base64Decode(b64);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _result = data;
        _photoBytes = photo;
        _error = null;
        _status = null;
      });
    } on MerchantApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _status = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Failed: $e\n\nIs merchant backend running at ${ApiConfig.baseUrl}?';
        _status = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _confirm() => Navigator.of(context).pop(true);

  List<MapEntry<String, String>> _fieldRows(Map<String, dynamic> data) {
    final fields = (data['fields'] is Map)
        ? Map<String, dynamic>.from(data['fields'] as Map)
        : <String, dynamic>{};
    final rows = <MapEntry<String, String>>[];
    void add(String label, dynamic v) {
      if (v == null) return;
      final s = v.toString().trim();
      if (s.isEmpty || s == 'null') return;
      rows.add(MapEntry(label, s));
    }

    add('Name', data['name'] ?? fields['name']);
    add('Date of Birth', data['dob'] ?? fields['dob'] ?? fields['dateOfBirth']);
    add('Gender', data['gender'] ?? fields['gender']);
    add('Address', data['address'] ?? fields['address']);
    add('Care of', fields['careOf']);
    add('House', fields['house']);
    add('Street', fields['street']);
    add('Landmark', fields['landmark']);
    add('Locality', fields['location']);
    add('VTC', fields['vtc']);
    add('Sub-district', fields['subDistrict']);
    add('District', fields['district']);
    add('State', fields['state']);
    add('Pin Code', fields['pincode'] ?? fields['pinCode']);
    add('Post office', fields['postOffice']);
    add('Aadhaar', fields['maskedAadhaar'] ?? fields['aadhaarNumber']);
    add('Reference ID', fields['referenceId']);
    final sig = data['digitalSignature'];
    if (sig is Map) {
      add('Signature valid', sig['isValid'] == true ? 'YES' : 'NO');
    }
    add('Stored in DB', data['storedInDatabase']?.toString());
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OC.surface3,
      appBar: AppBar(
        title: const Text('Aadhaar Secure QR'),
        backgroundColor: OC.surface,
        foregroundColor: OC.text,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Pyaadhaar Secure QR (server)',
                style: oSora(18, FontWeight.w700, OC.text),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a clear photo of the QR on Aadhaar (front is fine). '
                'Image is sent to your merchant backend for binary Secure QR '
                'decode (zlib + UIDAI RSA). Same Wi‑Fi as PC required.',
                style: oDm(13, FontWeight.w400, OC.text2),
              ),
              const SizedBox(height: 8),
              Text(
                'API: ${ApiConfig.aadhaarDecodeUrl}',
                style: oDm(11, FontWeight.w400, OC.text3),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OC.brandLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: OC.brand.withOpacity(0.25)),
                ),
                child: Text(
                  'Tips:\n'
                  '• QR square close-up (fills most of the frame)\n'
                  '• Good light, no flash glare\n'
                  '• Backend must be running on port ${ApiConfig.port}',
                  style: oDm(12, FontWeight.w500, OC.text),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _busy ? null : () => _pickAndUpload(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OC.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _pickAndUpload(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(_status!, style: oDm(12, FontWeight.w500, OC.brand)),
              ],
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (_result!['digitalSignature'] is Map &&
                            (_result!['digitalSignature']
                                    as Map)['isValid'] ==
                                true)
                        ? 'Secure QR OK · signature VALID · pyaadhaar backend'
                        : 'Decoded (check signature detail)',
                    style: const TextStyle(
                      color: Color(0xFF0F6E56),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_photoBytes != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_photoBytes!, height: 120),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ..._fieldRows(_result!).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            e.key,
                            style: oDm(12, FontWeight.w500, OC.text3),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: oDm(13, FontWeight.w500, OC.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OC.brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Confirm & return to KYC →'),
                ),
              ],
            ],
          ),
          if (_busy)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
