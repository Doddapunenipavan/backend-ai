import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of FlexTenure Merchant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      // Only clear the *session*, not the merchant's completed onboarding
      // record — so next time they just log back in instead of redoing KYC.
      await prefs.setBool('logged_in', false);
    } catch (_) {
      // Ignore — worst case the splash screen re-decides next cold start.
    }

    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sharma Electronics', style: AppTextStyles.h4(textColor)),
                        const SizedBox(height: 4),
                        Text('Merchant ID: FT-MER-1042', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _MenuGroup(
              textColor: textColor,
              items: [
                _MenuItem(Icons.storefront_outlined, 'Business Details', () => context.push('/profile/business-details')),
                _MenuItem(Icons.account_balance_outlined, 'Bank & Settlement', () => context.push('/profile/bank-settlement')),
                _MenuItem(Icons.inventory_2_outlined, 'Products', () => context.push('/dashboard/products')),
                _MenuItem(Icons.receipt_long_outlined, 'Statements', () => context.push('/dashboard/transactions')),
              ],
            ),
            const SizedBox(height: 16),
            _MenuGroup(
              textColor: textColor,
              items: [
                _MenuItem(Icons.notifications_outlined, 'Notifications', () => context.push('/profile/notifications')),
                _MenuItem(Icons.security_outlined, 'Security', () => context.push('/profile/security')),
                _MenuItem(Icons.settings_outlined, 'Settings', () => context.push('/profile/settings')),
                _MenuItem(Icons.help_outline_rounded, 'Help Center', () => context.push('/profile/help-center')),
              ],
            ),
            const SizedBox(height: 16),
            _MenuGroup(
              textColor: textColor,
              items: [
                _MenuItem(Icons.logout_rounded, 'Log Out', () => _logOut(context), isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.onTap, {this.isDestructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items, required this.textColor});
  final List<_MenuItem> items;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final color = item.isDestructive ? AppColors.error : textColor;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: item.isDestructive ? AppColors.error : AppColors.primary),
                title: Text(item.label, style: AppTextStyles.bodyMedium(color)),
                trailing: item.isDestructive
                    ? null
                    : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: item.onTap,
              ),
              if (i != items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}
