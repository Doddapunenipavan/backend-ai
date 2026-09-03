import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/text_fields/app_text_field.dart';

/// Standalone sign-in screen for returning merchants.
///
/// This is intentionally separate from the multi-step onboarding wizard:
/// onboarding is for brand-new merchants creating an account, while this
/// screen is the fast path back in for merchants who already completed
/// onboarding. On success it marks `onboarding_complete` and sends the
/// merchant straight to `/dashboard` — no need to re-run KYC etc.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginTab { otp, email }

class _LoginScreenState extends State<LoginScreen> {
  _LoginTab _tab = _LoginTab.otp;
  bool _isSubmitting = false;

  // OTP tab state
  final _phoneController = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocus = List.generate(6, (_) => FocusNode());

  // Email tab state
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _digitsOnlyPhone =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  void _sendOtp() {
    if (_digitsOnlyPhone.length < 10) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Enter a valid 10-digit mobile number')));
      return;
    }
    setState(() => _otpSent = true);
    NotificationService.instance.push(
      title: 'OTP sent',
      message: 'We sent a 6-digit code to +91 $_digitsOnlyPhone.',
      type: AppNotificationType.security,
    );
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocus[index + 1].requestFocus();
    }
    if (_otpControllers.every((c) => c.text.isNotEmpty)) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _otpVerified = true);
      Future.delayed(const Duration(milliseconds: 300), _completeLogin);
    } else {
      setState(() {});
    }
  }

  void _submitEmailLogin() {
    if (!_formKey.currentState!.validate()) return;
    _completeLogin();
  }

  Future<void> _completeLogin() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Mark the merchant as already onboarded so the splash screen sends
    // them straight to the dashboard on future cold starts, and persist
    // basic profile bits so other screens can reflect who's signed in.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setBool('logged_in', true);
      if (_tab == _LoginTab.otp) {
        await prefs.setString('auth_phone', _digitsOnlyPhone);
      } else {
        await prefs.setString('auth_email', _emailController.text.trim());
      }
    } catch (_) {
      // Worst case the session just won't persist across a cold start.
    }

    if (!mounted) return;

    NotificationService.instance.push(
      title: 'Welcome back',
      message: 'You\'ve successfully signed in to FlexTenure Merchant.',
      type: AppNotificationType.system,
    );

    context.go('/dashboard');
  }

  void _forgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Enter your email above first, then tap "Forgot password?"')));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(
              'Password reset link sent to ${_emailController.text.trim()}')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.textPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceAlt,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _logo(),
                    const SizedBox(height: 28),
                    Text('Welcome back',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2(textColor)),
                    const SizedBox(height: 6),
                    Text('Sign in to manage your business',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _tabSwitcher(),
                          const SizedBox(height: 20),
                          if (_tab == _LoginTab.otp) _otpBody() else _emailBody(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New merchant? ",
                            style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => context.go('/onboarding'),
                          child: Text('Create an account',
                              style: AppTextStyles.bodySmall(AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _tabSwitcher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget tabButton(_LoginTab tab, String label) {
      final active = _tab == tab;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? AppColors.surfaceAltDark : AppColors.surface)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? Border.all(color: isDark ? AppColors.borderDark : AppColors.border)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.labelMedium(
                active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        tabButton(_LoginTab.otp, 'Mobile OTP'),
        tabButton(_LoginTab.email, 'Email'),
      ]),
    );
  }

  Widget _otpBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Mobile Number',
          hint: '98765 43210',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          onChanged: (_) => setState(() => _otpSent = false),
        ),
        const SizedBox(height: 16),
        if (_otpVerified)
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('OTP verified — signing you in…',
                  style: AppTextStyles.bodySmall(AppColors.success)),
            ],
          )
        else ...[
          if (_otpSent && _digitsOnlyPhone.length >= 10) ...[
            Text('Enter the 6-digit code sent to +91 $_digitsOnlyPhone',
                style: AppTextStyles.bodySmall(AppColors.textSecondary)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 44,
                  height: 52,
                  child: TextField(
                    controller: _otpControllers[i],
                    focusNode: _otpFocus[i],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.h4(AppColors.primary),
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) => _onOtpDigitChanged(i, v),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _sendOtp,
                child: Text("Didn't receive it? Resend OTP",
                    style: AppTextStyles.bodySmall(AppColors.primary)),
              ),
            ),
            const SizedBox(height: 4),
          ] else
            PrimaryButton(label: 'Send OTP', onPressed: _sendOtp),
        ],
      ],
    );
  }

  Widget _emailBody() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email Address',
            hint: 'merchant@business.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Password',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            onChanged: (_) {},
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Must be at least 6 characters';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text('Forgot password?',
                  style: AppTextStyles.bodySmall(AppColors.primary)),
            ),
          ),
          const SizedBox(height: 6),
          PrimaryButton(
            label: 'Sign In',
            isLoading: _isSubmitting,
            onPressed: _submitEmailLogin,
          ),
        ],
      ),
    );
  }
}
