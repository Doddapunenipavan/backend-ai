import 'package:flutter/material.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';
import '../../../core/config/verification_links.dart';
import '../../../core/services/verification_link_screen.dart';
import '../../kyc/aadhaar_secure_qr_screen.dart';

class KycVerificationStep extends StatefulWidget {
  const KycVerificationStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<KycVerificationStep> createState() => _KycVerificationStepState();
}

class _KycVerificationStepState extends State<KycVerificationStep> {
  static const _types = [
    {
      'id': 'aadhaar',
      'icon': '🆔',
      'title': 'Aadhaar Secure QR',
      'sub': 'Offline UIDAI QR scan',
    },
    {
      'id': 'pan',
      'icon': '🪪',
      'title': 'PAN Verification',
      'sub': 'Income Tax Verify Your PAN',
    },
    {'id': 'video', 'icon': '🎥', 'title': 'Video KYC', 'sub': 'Live agent call'},
    {
      'id': 'digilocker',
      'icon': '🔒',
      'title': 'DigiLocker',
      'sub': 'Govt. document fetch',
    },
  ];

  final _panController = TextEditingController();
  final _nameController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url, String title) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VerificationLinkScreen(url: url, title: title),
      ),
    );
    if (done == true) {
      setState(() {
        widget.data.kycVerified = true;
        _error = null;
      });
    }
  }

  Future<void> _openAadhaarSecureQr() async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AadhaarSecureQrScreen()),
    );
    if (done == true && mounted) {
      setState(() {
        widget.data.kycType = 'aadhaar';
        widget.data.kycVerified = true;
        _error = null;
      });
    }
  }

  void _verifyPan() {
    final pan = _panController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
      setState(
        () => _error = 'Enter a valid 10-character PAN (e.g. AAFCS1234A).',
      );
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = 'Enter the name exactly as on the PAN card.');
      return;
    }
    widget.data.pan = pan;
    // Official Income Tax Verify Your PAN — in-app WebView + Done returns here
    _openLink(VerificationLinks.pan, 'Verify Your PAN');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(57),
        const SizedBox(height: 24),
        oPageTitle('KYC Verification', 'Complete identity verification to activate your account'),
        oCard(
          title: 'Select Verification Method',
          child: LayoutBuilder(
            builder: (ctx, c) {
              const gap = 12.0;
              final cols = c.maxWidth > 420 ? 2 : 1;
              final itemW = (c.maxWidth - (gap * (cols - 1))) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: _types.map((t) => SizedBox(width: itemW, child: _typeCard(t))).toList(),
              );
            },
          ),
        ),
        if (widget.data.kycType.isNotEmpty)
          oCard(
            title: widget.data.kycType == 'video' ? 'Face Verification' : 'Enter Details',
            child: _detailBody(),
          ),
        if (_error != null) oInfoRow(_error!, ok: false),
        oActionRow(
          onBack: widget.onBack,
          nextLabel: 'Continue to Bank Linking',
          onNext: widget.data.kycVerified
              ? widget.onNext
              : () => setState(() => _error = 'Please complete verification before continuing.'),
        ),
      ],
    );
  }

  Widget _typeCard(Map<String, String> t) {
    final selected = widget.data.kycType == t['id'];
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        widget.data.kycType = t['id']!;
        widget.data.kycVerified = false;
        _error = null;
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? OC.brandLight : OC.surface,
          border: Border.all(color: selected ? OC.brand : OC.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text(t['icon']!, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              if (selected)
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: OC.brand, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
            ]),
            const SizedBox(height: 10),
            Text(t['title']!, style: oDm(13, FontWeight.w600, OC.text), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(t['sub']!, style: oDm(11, FontWeight.w400, OC.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _detailBody() {
    switch (widget.data.kycType) {
      case 'aadhaar':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            oInfoRow(
              'Scan Aadhaar / eAadhaar Secure QR offline. '
              'UIDAI digital signature is verified first (never skipped). '
              'Invalid QR is rejected.',
            ),
            const SizedBox(height: 14),
            oBtn(
              'Scan Secure QR (offline) →',
              onTap: _openAadhaarSecureQr,
              primary: true,
              fullWidth: true,
            ),
            const SizedBox(height: 10),
            oBtn(
              'Optional: open myAadhaar portal',
              onTap: () =>
                  _openLink(VerificationLinks.aadhaar, 'myAadhaar'),
              primary: false,
              fullWidth: true,
            ),
            if (widget.data.kycVerified)
              oInfoRow('Aadhaar Secure QR verified!', ok: true),
          ],
        );
      case 'pan':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            oInfoRow(
              'Opens Income Tax “Verify Your PAN” in-app. '
              'After checking, tap Done to return to merchant onboarding.',
            ),
            const SizedBox(height: 10),
            oLabel('Name (as per PAN)'),
            oInput(hint: 'Full name on card', controller: _nameController),
            const SizedBox(height: 10),
            oLabel('PAN Number'),
            oInput(hint: 'AAFCS1234A', controller: _panController),
            const SizedBox(height: 14),
            oBtn(
              'Open Verify Your PAN →',
              onTap: _verifyPan,
              primary: true,
              fullWidth: true,
            ),
            if (widget.data.kycVerified)
              oInfoRow('PAN verification marked complete!', ok: true),
          ],
        );
      case 'digilocker':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            oInfoRow("You'll be redirected to DigiLocker to authorize document sharing."),
            const SizedBox(height: 14),
            oBtn(
              'Connect DigiLocker →',
              onTap: () => _openLink(VerificationLinks.digilocker, 'DigiLocker'),
              primary: true,
              fullWidth: true,
            ),
            if (widget.data.kycVerified) oInfoRow('KYC verified successfully!', ok: true),
          ],
        );
      case 'video':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: OC.surface2, border: Border.all(color: OC.border), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: OC.brandLight, border: Border.all(color: OC.brand, width: 3)),
                    child: const Text('😊', style: TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 14),
                  Text('Position your face within the circle and ensure good lighting',
                      textAlign: TextAlign.center, style: oDm(13, FontWeight.w400, OC.text2)),
                  const SizedBox(height: 14),
                  oBtn(
                    'Start Video KYC →',
                    onTap: () => _openLink(VerificationLinks.video, 'Video KYC'),
                    primary: true,
                  ),
                ],
              ),
            ),
            if (widget.data.kycVerified) oInfoRow('KYC verified successfully!', ok: true),
          ],
        );
    }
  }
}
