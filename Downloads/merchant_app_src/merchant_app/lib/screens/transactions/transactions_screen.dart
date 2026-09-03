import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';

class _Txn {
  const _Txn(this.name, this.date, this.amount, this.credit);
  final String name;
  final String date;
  final String amount;
  final bool credit;
}

const _txns = [
  _Txn('Rahul Mehta · EMI #4', '08 Jul 2026, 10:24 AM', '₹ 2,400', true),
  _Txn('Aman Joshi · EMI #2', '08 Jul 2026, 9:02 AM', '₹ 1,850', true),
  _Txn('Settlement to bank', '07 Jul 2026', '₹ 38,200', false),
  _Txn('Priya Patel · Advance', '06 Jul 2026', '₹ 4,200', true),
  _Txn('Refund · Neha Shah', '05 Jul 2026', '₹ 500', false),
];

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Transactions', showBackButton: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _txns.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, i) {
            final t = _txns[i];
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: t.credit ? AppColors.success.withOpacity(0.1) : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    t.credit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    size: 18,
                    color: t.credit ? AppColors.success : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: AppTextStyles.labelMedium(textColor)),
                      const SizedBox(height: 2),
                      Text(t.date, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${t.credit ? '+' : '-'} ${t.amount}',
                  style: AppTextStyles.labelMedium(t.credit ? AppColors.success : textColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
