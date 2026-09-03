import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_controller.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _autoReminders = false;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Preferences', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Push Notifications', style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('New payments and EMI due alerts', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                    value: _pushNotifications,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text('Email Alerts', style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('Daily settlement summary', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                    value: _emailAlerts,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text('Auto Payment Reminders', style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('Send reminders 1 day before EMI is due', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                    value: _autoReminders,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _autoReminders = v),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text('Dark Mode', style: AppTextStyles.bodyMedium(textColor)),
                    value: ThemeController.isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => ThemeController.setDarkMode(v)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
