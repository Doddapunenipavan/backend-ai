import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/notifications/notification_bell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.storefront_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning',
                                style: AppTextStyles.bodySmall(
                                    AppColors.textSecondary)),
                            Text('Sharma Electronics',
                                style: AppTextStyles.h3(textColor)),
                          ],
                        ),
                      ],
                    ),
                    const NotificationBell(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: GradientStatCard(
                  label: "This Month's Collections",
                  value: '₹ 4,82,600',
                  deltaLabel: '12.4% vs last month',
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildListDelegate([
                  const KpiCard(
                      label: 'Active Customers',
                      value: '186',
                      icon: Icons.groups_rounded,
                      deltaLabel: '+8 this week'),
                  const KpiCard(
                      label: 'Pending EMIs',
                      value: '32',
                      icon: Icons.schedule_rounded,
                      deltaLabel: '4 due today',
                      isPositiveDelta: false),
                  const KpiCard(
                      label: 'Overdue Amount',
                      value: '₹ 18,400',
                      icon: Icons.warning_amber_rounded,
                      deltaLabel: '6 accounts',
                      isPositiveDelta: false),
                  const KpiCard(
                      label: 'Products Listed',
                      value: '54',
                      icon: Icons.inventory_2_rounded,
                      deltaLabel: '+3 new'),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child:
                    Text('Quick Actions', style: AppTextStyles.h4(textColor)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Collect\nPayment',
                        onTap: () => context.push('/payments/collect'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Add\nCustomer',
                        onTap: () => context.push('/customers/add'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_box_rounded,
                        label: 'Add\nProduct',
                        onTap: () => context.push('/dashboard/products/add'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.receipt_long_rounded,
                        label: 'View\nStatements',
                        onTap: () => context.push('/dashboard/transactions'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: AppTextStyles.h4(textColor)),
                    TextButton(
                      onPressed: () => context.push('/dashboard/transactions'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: _activity.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _activity[index];
                  final iconColor = item.icon == Icons.warning_amber_rounded
                      ? AppColors.warning
                      : item.icon == Icons.arrow_downward_rounded
                          ? AppColors.success
                          : AppColors.primary;
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(item.icon, color: iconColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: AppTextStyles.labelMedium(textColor)),
                              const SizedBox(height: 2),
                              Text(item.subtitle,
                                  style: AppTextStyles.bodySmall(
                                      AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(item.amount,
                            style: AppTextStyles.labelMedium(textColor)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem(this.icon, this.title, this.subtitle, this.amount);
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
}

const _activity = [
  _ActivityItem(Icons.arrow_downward_rounded, 'Payment received',
      'Rahul Mehta · EMI #4', '+ ₹ 2,400'),
  _ActivityItem(Icons.person_add_alt_1_rounded, 'New customer onboarded',
      'Priya Patel · iPhone 14', '₹ 42,000'),
  _ActivityItem(Icons.arrow_downward_rounded, 'Payment received',
      'Aman Joshi · EMI #2', '+ ₹ 1,850'),
  _ActivityItem(Icons.warning_amber_rounded, 'EMI overdue',
      'Kiran Rao · EMI #6', '₹ 3,200'),
];
