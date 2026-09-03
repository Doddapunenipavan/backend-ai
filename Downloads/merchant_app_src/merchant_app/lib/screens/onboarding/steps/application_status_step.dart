import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

class ApplicationStatusStep extends StatefulWidget {
  const ApplicationStatusStep({super.key, required this.data});
  final OnboardingData data;

  @override
  State<ApplicationStatusStep> createState() => _ApplicationStatusStepState();
}

class _ApplicationStatusStepState extends State<ApplicationStatusStep> {
  @override
  Widget build(BuildContext context) {
    final cfg = {
      'approved': {
        'icon': Icons.check_rounded,
        'title': "Congratulations! You're approved",
        'sub':
            'Your merchant account is now active. Start accepting payments on FlexTenure.',
        'color': OC.success,
        'bg': OC.successBg,
      },
      'rejected': {
        'icon': Icons.close_rounded,
        'title': 'Application not approved',
        'sub':
            "Unfortunately we couldn't approve your application at this time. You may reapply after 30 days.",
        'color': OC.danger,
        'bg': OC.dangerBg,
      },
      'pending': {
        'icon': Icons.hourglass_top_rounded,
        'title': 'Application under review',
        'sub':
            'Our team is reviewing your documents. This usually takes 1–2 business days.',
        'color': OC.warning,
        'bg': OC.warningBg,
      },
    }[widget.data.approvalStatus]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(100),
        const SizedBox(height: 24),
        oPageTitle('Application Status', 'Review and onboarding outcome'),
        oCard(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cfg['bg'] as Color,
                ),
                child: Icon(cfg['icon'] as IconData,
                    size: 40, color: cfg['color'] as Color),
              ),
              const SizedBox(height: 20),
              Text(
                cfg['title'] as String,
                textAlign: TextAlign.center,
                style:
                    oSora(20, FontWeight.w700, cfg['color'] as Color, ls: -0.3),
              ),
              const SizedBox(height: 8),
              Text(
                cfg['sub'] as String,
                textAlign: TextAlign.center,
                style: oDm(13, FontWeight.w400, OC.text2),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  if (widget.data.approvalStatus == 'approved') ...[
                    oBtn('Go to Dashboard →',
                        primary: true, onTap: _completeOnboarding),
                    oBtn('Download Agreement', onTap: _downloadAgreement),
                  ] else if (widget.data.approvalStatus == 'rejected') ...[
                    oBtn('View Reason', onTap: _viewReason, danger: true),
                    oBtn('Contact Support', onTap: _contactSupport),
                  ] else
                    oBtn('Track Application', onTap: _trackApplication),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        oCard(
          title: 'Review Summary',
          child: Column(
            children: [
              _reviewRow(
                  'Business Name',
                  widget.data.businessName.isEmpty
                      ? 'Acme Pvt. Ltd.'
                      : widget.data.businessName),
              _reviewRow('Merchant ID', widget.data.merchantId, mono: true),
              _reviewRow('KYC Status', '✓ Verified', color: OC.success),
              _reviewRow('Bank Account', '✓ Linked', color: OC.success),
              _reviewRow('Documents', '✓ Uploaded', color: OC.success),
              _reviewRow('Agreement', '✓ Signed', color: OC.success),
              _reviewRow('Submitted On', oTodayStr()),
            ],
          ),
        ),
        // DEV-ONLY: lets you preview all 3 states while testing. Wrapped in
        // kDebugMode so this never ships to the Play Store build — release
        // builds compile this whole block out entirely.
        if (kDebugMode)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              oBtn('Simulate Approved',
                  onTap: () =>
                      setState(() => widget.data.approvalStatus = 'approved'),
                  success: true,
                  small: true),
              oBtn('Simulate Pending',
                  onTap: () =>
                      setState(() => widget.data.approvalStatus = 'pending'),
                  small: true),
              oBtn('Simulate Rejected',
                  onTap: () =>
                      setState(() => widget.data.approvalStatus = 'rejected'),
                  danger: true,
                  small: true),
            ],
          ),
      ],
    );
  }

  Future<void> _downloadAgreement() async {
    // NOTE: no real PDF is generated/stored yet — plug in your actual
    // signed-agreement file URL (from your backend) here once you have
    // one. For now this shows a clear, honest message instead of
    // pretending a download happened.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your agreement PDF will be emailed to you shortly.')),
    );
  }

  void _viewReason() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reason for rejection'),
        // NOTE: static copy for now — wire this to the real rejection
        // reason from your backend/review-team once that data exists.
        content: const Text(
          'Your application could not be approved at this time. This is usually due to a document mismatch or incomplete KYC details. Our team will email you the specific reason within 1–2 business days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@flextenure.com',
      query: 'subject=${Uri.encodeComponent("Merchant application query — ${widget.data.merchantId}")}',
    );
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open your email app. Reach us at support@flextenure.com")),
      );
    }
  }

  void _trackApplication() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Application status'),
        content: const Text(
          'Your application is under review. Our team typically completes this within 1–2 business days. You\'ll get a notification the moment there\'s an update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Marks onboarding as complete AND clears the step tracker, so that:
  /// - Next cold start goes straight to /dashboard
  /// - If user ever logs out and re-onboards, they start fresh at step 1
  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setBool('logged_in', true);
      await prefs.remove('onboarding_current_step');
      await prefs.remove('onboarding_completed_steps');
    } catch (_) {
      // Ignore — worst case they see splash again next time.
    }
    if (mounted) context.go('/dashboard');
  }

  Widget _reviewRow(String key, String value,
      {Color? color, bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: OC.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: oDm(13, FontWeight.w400, OC.text2)),
          Text(
            value,
            style: mono
                ? TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: color ?? OC.text,
                    fontWeight: FontWeight.w600,
                  )
                : oDm(13, FontWeight.w600, color ?? OC.text),
          ),
        ],
      ),
    );
  }
}
