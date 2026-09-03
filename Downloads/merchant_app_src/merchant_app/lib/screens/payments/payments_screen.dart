import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';

class _Payment {
  const _Payment(this.name, this.date, this.amount, this.status, this.type);
  final String name;
  final String date;
  final String amount;
  final String status;
  final StatusChipType type;
}

const _payments = [
  _Payment('Rahul Mehta', 'Today, 10:24 AM', '₹ 2,400', 'Received', StatusChipType.success),
  _Payment('Aman Joshi', 'Today, 9:02 AM', '₹ 1,850', 'Received', StatusChipType.success),
  _Payment('Kiran Rao', 'Due yesterday', '₹ 3,200', 'Overdue', StatusChipType.error),
  _Payment('Neha Shah', 'Due in 2 days', '₹ 2,750', 'Upcoming', StatusChipType.warning),
];

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Payments'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PrimaryButton(
              label: 'Collect Payment',
              icon: Icons.qr_code_scanner_rounded,
              onPressed: () => context.push('/payments/collect'),
            ),
            const SizedBox(height: 20),
            Text('Recent & Upcoming', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            ...List.generate(_payments.length, (i) {
              final p = _payments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: AppTextStyles.labelMedium(textColor)),
                            const SizedBox(height: 2),
                            Text(p.date, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(p.amount, style: AppTextStyles.labelMedium(textColor)),
                          const SizedBox(height: 6),
                          StatusChip(label: p.status, status: p.type),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
