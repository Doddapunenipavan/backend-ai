import 'package:flutter/material.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  bool _payments = true;
  bool _settlements = true;
  bool _promotions = false;
  bool _productUpdates = true;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          AnimatedBuilder(
            animation: NotificationService.instance,
            builder: (context, _) => NotificationService.instance.unreadCount > 0
                ? TextButton(
                    onPressed: () => NotificationService.instance.markAllRead(),
                    child: const Text('Mark all read'),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: 'Activity'), Tab(text: 'Settings')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _activityTab(textColor),
                  _settingsTab(textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Live activity feed ----------------
  Widget _activityTab(Color textColor) {
    return AnimatedBuilder(
      animation: NotificationService.instance,
      builder: (context, _) {
        final items = NotificationService.instance.items;
        if (items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 80),
              Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'No notifications yet.\nYou\'ll see live updates here as things happen.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(AppColors.textSecondary),
                ),
              ),
            ],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _NotificationTile(
            notification: items[i],
            textColor: textColor,
            onTap: () => NotificationService.instance.markRead(items[i].id),
          ),
        );
      },
    );
  }

  // ---------------- Preference toggles ----------------
  Widget _settingsTab(Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _NotificationSwitch(
                icon: Icons.payments_outlined,
                title: 'Payment Alerts',
                subtitle: 'Get notified for every transaction',
                value: _payments,
                textColor: textColor,
                onChanged: (v) => setState(() => _payments = v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _NotificationSwitch(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Settlement Updates',
                subtitle: 'Payout status and confirmations',
                value: _settlements,
                textColor: textColor,
                onChanged: (v) => setState(() => _settlements = v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _NotificationSwitch(
                icon: Icons.campaign_outlined,
                title: 'Promotions & Offers',
                subtitle: 'Occasional offers from FlexTenure',
                value: _promotions,
                textColor: textColor,
                onChanged: (v) => setState(() => _promotions = v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _NotificationSwitch(
                icon: Icons.system_update_outlined,
                title: 'Product Updates',
                subtitle: 'New features and app updates',
                value: _productUpdates,
                textColor: textColor,
                onChanged: (v) => setState(() => _productUpdates = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.textColor, required this.onTap});

  final AppNotification notification;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: notification.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notification.icon, color: notification.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.bodyMedium(textColor).copyWith(
                          fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notification.read)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6, top: 4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(notification.message, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(notification.relativeTime,
                    style: AppTextStyles.bodySmall(AppColors.textSecondary.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.textColor,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color textColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium(textColor)),
      subtitle: Text(subtitle,
          style: AppTextStyles.bodySmall(AppColors.textSecondary)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
