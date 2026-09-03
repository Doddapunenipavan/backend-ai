import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart'; 
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

class DocumentUploadStep extends StatefulWidget {
  const DocumentUploadStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends State<DocumentUploadStep> {
  final _picker = ImagePicker();

  static const _docs = [
    {'name': 'GST Certificate', 'icon': '🧾'},
    {'name': 'PAN Card', 'icon': '🪪'},
    {'name': 'Aadhaar Card', 'icon': '🆔'},
    {'name': 'Business Registration', 'icon': '📋'},
  ];

  Future<void> _pickFile(String docName) async {
    // Show source picker bottom sheet
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: OC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OC.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Upload $docName', style: oSora(16, FontWeight.w600, OC.text)),
            const SizedBox(height: 4),
            Text('Choose a source', style: oDm(13, FontWeight.w400, OC.text3)),
            const SizedBox(height: 20),
            _sheetOption(
              ctx,
              Icons.camera_alt_outlined,
              'Camera',
              'Take a photo',
              'camera',
            ),
            const SizedBox(height: 10),
            _sheetOption(
              ctx,
              Icons.photo_library_outlined,
              'Gallery',
              'Choose from photos',
              'gallery',
            ),
            const SizedBox(height: 10),
            _sheetOption(
              ctx,
              Icons.description_outlined,
              'File Browser',
              'PDF, JPG, PNG (max 10 MB)',
              'file',
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      UploadedDoc? doc;

      if (source == 'camera') {
        final XFile? img = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 2000,
        );
        if (img != null) doc = await _toUploadedDoc(img.path);
      } else if (source == 'gallery') {
        final XFile? img = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 2000,
        );
        if (img != null) doc = await _toUploadedDoc(img.path);
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false,
        );
        if (result != null && result.files.single.path != null) {
          doc = await _toUploadedDoc(result.files.single.path!);
        }
      }

      if (doc == null || !mounted) return;

      // Size check — 10 MB limit
      if (doc.sizeBytes > 10 * 1024 * 1024) {
        _showSnack('File too large. Max 10 MB.', isError: true);
        return;
      }

      setState(() => widget.data.documents[docName] = doc);

      NotificationService.instance.push(
        title: 'Document uploaded',
        message: '$docName (${doc.sizeReadable}) uploaded successfully.',
        type: AppNotificationType.onboarding,
      );

      _showSnack('$docName uploaded');
    } catch (e) {
      if (mounted) _showSnack('Upload failed: $e', isError: true);
    }
  }

  Future<UploadedDoc> _toUploadedDoc(String path) async {
    final file = File(path);
    final size = await file.length();
    return UploadedDoc(
      name: p.basename(path),
      path: path,
      sizeBytes: size,
      extension: p.extension(path).replaceFirst('.', '').toUpperCase(),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? OC.danger : OC.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _sheetOption(
      BuildContext ctx, IconData icon, String title, String sub, String value) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: OC.border, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OC.brandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: OC.brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: oDm(14, FontWeight.w600, OC.text)),
                  Text(sub, style: oDm(11, FontWeight.w400, OC.text3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: OC.text3),
          ],
        ),
      ),
    );
  }

  Future<void> _previewDoc(UploadedDoc doc) async {
    if (['JPG', 'JPEG', 'PNG'].contains(doc.extension)) {
      await showDialog(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.file(File(doc.path), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${doc.name} · ${doc.sizeReadable}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      _showSnack('Preview not available for ${doc.extension}');
    }
  }

  void _removeDoc(String docName) {
    setState(() => widget.data.documents[docName] = null);
    _showSnack('$docName removed');
  }

  void _proceed() {
    if (!widget.data.allDocumentsUploaded) {
      _showSnack('Please upload all required documents', isError: true);
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(42),
        const SizedBox(height: 24),
        oPageTitle(
            'Document Upload', 'Upload required documents for verification'),
        oCard(
          title: 'Required Documents',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final d in _docs) _docItem(d),
              const SizedBox(height: 6),
              _bulkUploadArea(),
            ],
          ),
        ),
        oInfoRow(
          'All documents are encrypted and stored securely. We comply with RBI guidelines.',
        ),
        oActionRow(
          onBack: widget.onBack,
          nextLabel: 'Proceed to KYC',
          onNext: _proceed,
        ),
      ],
    );
  }

  Widget _docItem(Map<String, String> meta) {
    final name = meta['name']!;
    final icon = meta['icon']!;
    final uploaded = widget.data.documents[name];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OC.surface2,
        border: Border.all(color: OC.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OC.brandLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: oDm(13, FontWeight.w600, OC.text)),
                    Text(
                      uploaded != null
                          ? '${uploaded.extension} · ${uploaded.sizeReadable}'
                          : 'Required · PDF or JPG',
                      style: oDm(11, FontWeight.w400, OC.text3),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: uploaded != null ? OC.successBg : OC.warningBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  uploaded != null ? '✓ Uploaded' : 'Pending',
                  style: oDm(11, FontWeight.w600,
                      uploaded != null ? OC.success : OC.warning),
                ),
              ),
            ],
          ),
          if (uploaded != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewDoc(uploaded),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text('Preview',
                        style: oSora(12, FontWeight.w500, OC.brand)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OC.brand,
                      side: const BorderSide(color: OC.brand, width: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFile(name),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text('Replace',
                        style: oSora(12, FontWeight.w500, OC.text2)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OC.text2,
                      side: const BorderSide(color: OC.border2, width: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _removeDoc(name),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text('Remove',
                        style: oSora(12, FontWeight.w500, OC.danger)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OC.danger,
                      side: const BorderSide(color: OC.danger, width: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickFile(name),
                icon: const Icon(Icons.upload_file, size: 16),
                label: Text('Upload $name',
                    style: oSora(13, FontWeight.w600, OC.brand)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: OC.brand,
                  backgroundColor: OC.brandLight,
                  side: const BorderSide(color: OC.brand, width: 0.7),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bulkUploadArea() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        // Bulk-pick multiple files
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: true,
        );
        if (result == null || !mounted) return;

        // Assign in order to any empty slots
        int assigned = 0;
        for (final f in result.files) {
          if (f.path == null) continue;
          for (final key in widget.data.documents.keys) {
            if (widget.data.documents[key] == null) {
              widget.data.documents[key] = await _toUploadedDoc(f.path!);
              assigned++;
              break;
            }
          }
        }
        if (mounted) {
          setState(() {});
          _showSnack('$assigned document(s) auto-assigned');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: OC.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OC.border2, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OC.surface,
                shape: BoxShape.circle,
                border: Border.all(color: OC.border2),
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  color: OC.brand, size: 20),
            ),
            const SizedBox(height: 10),
            Text.rich(
                TextSpan(style: oDm(13, FontWeight.w400, OC.text2), children: [
              TextSpan(
                  text: 'Bulk upload',
                  style: oDm(13, FontWeight.w600, OC.brand)),
              const TextSpan(text: ' — auto-assign multiple files'),
            ])),
            const SizedBox(height: 4),
            Text('PDF, JPG, PNG up to 10 MB each',
                style: oDm(11, FontWeight.w400, OC.text3)),
          ],
        ),
      ),
    );
  }
}
