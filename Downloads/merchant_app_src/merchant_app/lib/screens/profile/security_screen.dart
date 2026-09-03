import 'package:flutter/material.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/text_fields/app_text_field.dart';

class _Session {
  _Session(this.device, this.location, this.lastActive, {this.isCurrent = false});
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometric = true;
  bool _twoFactor = false;

  final List<_Session> _sessions = [
    _Session('This device • Android', 'Ahmedabad, IN', 'Active now', isCurrent: true),
    _Session('Chrome on Windows', 'Jamnagar, IN', '2 days ago'),
    _Session('Safari on iPhone', 'Mumbai, IN', '5 days ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Security'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.primary),
                    title: Text('Change Password',
                        style: AppTextStyles.bodyMedium(textColor)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded,
                        color: AppColors.primary),
                    title: Text('Biometric Login',
                        style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('Use fingerprint or face unlock',
                        style:
                            AppTextStyles.bodySmall(AppColors.textSecondary)),
                    value: _biometric,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => _biometric = v);
                      NotificationService.instance.push(
                        title: v ? 'Biometric login enabled' : 'Biometric login disabled',
                        message: v
                            ? 'You can now sign in with fingerprint or face unlock.'
                            : 'Fingerprint/face unlock has been turned off.',
                        type: AppNotificationType.security,
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.verified_user_outlined,
                        color: AppColors.primary),
                    title: Text('Two-Factor Authentication',
                        style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('Extra layer of security via OTP',
                        style:
                            AppTextStyles.bodySmall(AppColors.textSecondary)),
                    value: _twoFactor,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => _twoFactor = v);
                      NotificationService.instance.push(
                        title: v ? 'Two-factor authentication enabled' : 'Two-factor authentication disabled',
                        message: v
                            ? 'An OTP will now be required on every sign-in.'
                            : 'OTP will no longer be required on sign-in.',
                        type: AppNotificationType.security,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.devices_other_rounded,
                    color: AppColors.primary),
                title: Text('Active Sessions',
                    style: AppTextStyles.bodyMedium(textColor)),
                subtitle: Text('${_sessions.length} devices currently logged in',
                    style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                onTap: () => _showActiveSessions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text('Change Password',
                          style: AppTextStyles.h4(
                              Theme.of(sheetContext).textTheme.bodyMedium?.color ??
                                  AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Current Password',
                        hint: '••••••••',
                        controller: currentController,
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter your current password' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'New Password',
                        hint: 'At least 8 characters',
                        controller: newController,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a new password';
                          if (v.length < 8) return 'Must be at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: 'Re-enter new password',
                        controller: confirmController,
                        obscureText: true,
                        validator: (v) {
                          if (v != newController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Update Password',
                        isLoading: submitting,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setSheetState(() => submitting = true);
                          await Future.delayed(const Duration(milliseconds: 700));
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();
                          NotificationService.instance.push(
                            title: 'Password updated',
                            message: 'Your account password was changed successfully.',
                            type: AppNotificationType.security,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                  content: Text('Password updated successfully')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showActiveSessions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final textColor = Theme.of(sheetContext).textTheme.bodyMedium?.color ??
                AppColors.textPrimary;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Active Sessions', style: AppTextStyles.h4(textColor)),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _sessions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = _sessions[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            s.device.toLowerCase().contains('iphone')
                                ? Icons.phone_iphone_rounded
                                : s.device.toLowerCase().contains('android')
                                    ? Icons.phone_android_rounded
                                    : Icons.laptop_mac_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text(s.device, style: AppTextStyles.bodyMedium(textColor)),
                          subtitle: Text('${s.location} • ${s.lastActive}',
                              style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                          trailing: s.isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('This device',
                                      style: AppTextStyles.caption(AppColors.success)),
                                )
                              : TextButton(
                                  onPressed: () {
                                    setSheetState(() => _sessions.removeAt(i));
                                    setState(() {});
                                    NotificationService.instance.push(
                                      title: 'Session revoked',
                                      message: '${s.device} was signed out.',
                                      type: AppNotificationType.security,
                                    );
                                  },
                                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                  child: const Text('Revoke'),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
