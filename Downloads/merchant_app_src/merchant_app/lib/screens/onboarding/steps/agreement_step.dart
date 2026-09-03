import 'package:flutter/material.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/config/verification_links.dart';
import '../../../core/services/verification_link_screen.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

class AgreementStep extends StatefulWidget {
  const AgreementStep({super.key, required this.data, required this.onNext, required this.onBack});

  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<AgreementStep> createState() => _AgreementStepState();
}

class _AgreementStepState extends State<AgreementStep> {
  static const clauses = [
    'I confirm the business details provided are accurate and complete.',
    'I authorize FlexTenure to conduct KYC and credit checks as required.',
    'I agree to the merchant fee structure and settlement cycle terms.',
  ];

  final checks = [false, false, false];

  Future<void> _eSign() async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const VerificationLinkScreen(url: VerificationLinks.esign, title: 'e-Sign Agreement'),
      ),
    );
    if (done == true) setState(() => widget.data.signed = true);
  }

  void _submit() {
    if (!checks.every((c) => c) || !widget.data.signed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept all terms and add your digital signature to submit.')),
      );
      return;
    }
    NotificationService.instance.push(
      title: 'Application submitted',
      message: 'Your merchant agreement was signed and the application has been submitted for review.',
      type: AppNotificationType.onboarding,
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(86),
        const SizedBox(height: 28),
        oPageTitle('Merchant Agreement', 'Read and sign the merchant onboarding agreement'),
        oCard(
          title: 'FlexTenure Merchant Terms',
          child: Container(
            constraints: const BoxConstraints(maxHeight: 220),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: OC.surface2, border: Border.all(color: OC.border), borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Merchant Services Agreement', style: oSora(14, FontWeight.w500, OC.text)),
                const SizedBox(height: 10),
                Text(
                  'This Merchant Services Agreement ("Agreement") is entered into between FlexTenure Financial Technologies Pvt. Ltd. and the Merchant identified in the onboarding application.\n\n'
                  '1. Services. FlexTenure provides access to its subscription payment processing platform, including settlement, reconciliation, and credit services.\n\n'
                  '2. Merchant Obligations. The Merchant agrees to maintain accurate records and comply with PMLA and applicable laws.\n\n'
                  '3. Settlement. Settlements are processed within T+2 business days, subject to holds or disputes.\n\n'
                  '4. Fees. Platform fees as communicated during onboarding; revisions require 30 days notice.\n\n'
                  '5. Data & Privacy. Data handled per FlexTenure\'s Privacy Policy; never sold to third parties.\n\n'
                  '6. Termination. Either party may terminate with 30 days notice; immediate for fraud.',
                  style: oDm(13, FontWeight.w400, OC.text2),
                ),
              ]),
            ),
          ),
        ),
        oCard(
          child: Column(
            children: List.generate(clauses.length, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: i < clauses.length - 1 ? const Border(bottom: BorderSide(color: OC.border, width: 0.5)) : null,
                ),
                child: InkWell(
                  onTap: () => setState(() => checks[i] = !checks[i]),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 1),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: checks[i] ? OC.brand : OC.surface,
                        border: Border.all(color: checks[i] ? OC.brand : OC.border2, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: checks[i] ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(clauses[i], style: oDm(13, FontWeight.w400, OC.text2))),
                  ]),
                ),
              );
            }),
          ),
        ),
        oCard(
          title: 'Digital Signature',
          child: InkWell(
            onTap: widget.data.signed ? null : _eSign,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.data.signed ? OC.successBg : OC.surface,
                border: Border.all(color: widget.data.signed ? OC.success : OC.border2, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.data.signed
                  ? Column(children: [
                      Text('Authorized Signatory', style: oSora(24, FontWeight.w400, OC.success)),
                      const SizedBox(height: 4),
                      Text('Signed on ${oTodayStr()}', style: oDm(12, FontWeight.w400, OC.success)),
                    ])
                  : Column(children: [
                      Text('Tap to e-Sign via Digio', style: oDm(13, FontWeight.w400, OC.text3)),
                      const SizedBox(height: 4),
                      Text('Uses Aadhaar e-sign or OTP-based signature', style: oDm(11, FontWeight.w400, OC.text3)),
                    ]),
            ),
          ),
        ),
        oActionRow(onBack: widget.onBack, nextLabel: 'Submit Application', onNext: _submit),
      ],
    );
  }
}
