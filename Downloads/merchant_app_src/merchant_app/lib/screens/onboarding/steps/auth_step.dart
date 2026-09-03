import 'package:flutter/material.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

/// Step 1 of the onboarding flow — "Welcome to FlexTenure / Create your
/// merchant account to get started". This is the login/register screen from
/// the screenshots (Mobile OTP tab, Email tab, and Continue-with OAuth tab).
class AuthStep extends StatefulWidget {
  const AuthStep({super.key, required this.data, required this.onNext});

  final OnboardingData data;
  final VoidCallback onNext;

  @override
  State<AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends State<AuthStep> {
  String authTab = 'otp';
  String authPhone = '';
  bool otpSent = false;
  bool otpVerified = false;
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocus = List.generate(6, (_) => FocusNode());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  void _deferredSetState(VoidCallback fn) {
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) setState(fn);
    });
  }

  void _completeAuth() {
    widget.data.authenticated = true;
    NotificationService.instance.push(
      title: 'Welcome to FlexTenure',
      message: 'Your merchant account has been created. Let\'s set up your business.',
      type: AppNotificationType.onboarding,
    );
    widget.onNext();
  }

  @override
  void dispose() {
    for (final c in otpControllers) c.dispose();
    for (final f in otpFocus) f.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: OC.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: ['otp', 'email', 'oauth'].map((t) {
          final active = authTab == t;
          final label = t == 'otp' ? 'Mobile OTP' : (t == 'email' ? 'Email' : 'Continue with');
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => authTab = t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: active ? OC.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: active ? Border.all(color: OC.border, width: 0.7) : null,
                ),
                alignment: Alignment.center,
                child: Text(label, style: oDm(13, active ? FontWeight.w500 : FontWeight.w400, active ? OC.text : OC.text2)),
              ),
            ),
          );
        }).toList(),
      ),
    );

    Widget body;
    if (authTab == 'otp') {
      body = _otpBody();
    } else if (authTab == 'email') {
      body = _emailBody();
    } else {
      body = _oauthBody();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(14),
        const SizedBox(height: 28),
        oPageTitle('Welcome to FlexTenure', 'Create your merchant account to get started'),
        oCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tabs, const SizedBox(height: 16), body])),
        if (otpVerified) oActionRow(showBack: false, nextLabel: 'Continue to Business Details', onNext: _completeAuth),
      ],
    );
  }

  Widget _otpBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oLabel('Mobile Number'),
        Row(children: [
          SizedBox(width: 80, child: oInput(hint: '+91')),
          const SizedBox(width: 8),
          Expanded(
            child: oInput(
              hint: '98765 43210',
              type: TextInputType.phone,
              onChanged: (v) => setState(() {
                authPhone = v.replaceAll(RegExp(r'\D'), '');
                otpSent = false;
              }),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        if (otpVerified)
          oInfoRow('OTP verified successfully', ok: true)
        else ...[
          if (otpSent && authPhone.length >= 10) ...[
            Text('Enter OTP sent to +91 $authPhone', style: oDm(12, FontWeight.w500, OC.text2)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 44,
                    height: 50,
                    child: TextField(
                      controller: otpControllers[i],
                      focusNode: otpFocus[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: oSora(20, FontWeight.w500, OC.brand),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: OC.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: OC.border2, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: OC.brand, width: 1.5)),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) otpFocus[i + 1].requestFocus();
                        if (otpControllers.every((c) => c.text.isNotEmpty)) {
                          _unfocus();
                          widget.data.phone = authPhone;
                          _deferredSetState(() => otpVerified = true);
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: InkWell(
                onTap: () => NotificationService.instance.push(
                  title: 'OTP resent',
                  message: 'A new OTP has been sent to +91 $authPhone.',
                  type: AppNotificationType.security,
                ),
                child: Text.rich(TextSpan(
                  style: oDm(12, FontWeight.w400, OC.text3),
                  children: [
                    const TextSpan(text: "Didn't receive? "),
                    TextSpan(text: 'Resend OTP', style: oDm(12, FontWeight.w500, OC.brand)),
                  ],
                )),
              ),
            ),
          ],
          const SizedBox(height: 14),
          oBtn(
            otpSent && authPhone.length >= 10 ? 'Verify OTP' : 'Send OTP',
            onTap: () {
              if (authPhone.length < 10) return;
              setState(() => otpSent = true);
              NotificationService.instance.push(
                title: 'OTP sent',
                message: 'We sent a 6-digit code to +91 $authPhone.',
                type: AppNotificationType.security,
              );
            },
            primary: true,
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _emailBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oLabel('Email Address'),
        oInput(
          hint: 'merchant@business.com',
          type: TextInputType.emailAddress,
          controller: emailController,
          onChanged: (v) => widget.data.email = v,
        ),
        const SizedBox(height: 12),
        oLabel('Password'),
        oInput(hint: '••••••••', controller: passwordController),
        const SizedBox(height: 14),
        oBtn('Sign In →', onTap: _completeAuth, primary: true, fullWidth: true),
        const SizedBox(height: 12),
        Center(
          child: Text.rich(TextSpan(style: oDm(12, FontWeight.w400, OC.text3), children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(text: 'Create one', style: oDm(12, FontWeight.w500, OC.brand)),
          ])),
        ),
      ],
    );
  }

  Widget _oauthBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _oauthBtn('Continue with Google', Icons.g_mobiledata_rounded),
        const SizedBox(height: 10),
        _oauthBtn('Continue with GitHub', Icons.code_rounded),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Divider(color: OC.border)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or use email / OTP', style: oDm(12, FontWeight.w400, OC.text3))),
          const Expanded(child: Divider(color: OC.border)),
        ]),
        const SizedBox(height: 4),
        oBtn('Sign in with Email', onTap: () => setState(() => authTab = 'email'), fullWidth: true),
      ],
    );
  }

  Widget _oauthBtn(String label, IconData icon) {
    return InkWell(
      onTap: _completeAuth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(border: Border.all(color: OC.border2, width: 0.7), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 18, color: OC.text2),
          const SizedBox(width: 12),
          Text(label, style: oDm(14, FontWeight.w400, OC.text)),
        ]),
      ),
    );
  }
}
