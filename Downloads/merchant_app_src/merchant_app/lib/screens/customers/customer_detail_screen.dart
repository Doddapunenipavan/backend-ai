import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Customer Details', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySurface,
                    child: Text('R', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rahul Mehta', style: AppTextStyles.h4(textColor)),
                        const SizedBox(height: 4),
                        Text('+91 98765 43210', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const StatusChip(label: 'On Track', status: StatusChipType.success),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('EMI Plan', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _row('Product', 'Samsung Galaxy S23'),
                  const Divider(height: 20),
                  _row('Total Amount', '₹ 28,800'),
                  const Divider(height: 20),
                  _row('Monthly EMI', '₹ 2,400'),
                  const Divider(height: 20),
                  _row('Progress', '4 of 12 paid'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Payment Schedule', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            ...List.generate(4, (i) {
              final paid = i < 3;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      Icon(
                        paid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        color: paid ? AppColors.success : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('EMI ${i + 1} · Due 05 ${['Apr', 'May', 'Jun', 'Jul'][i]} 2026',
                            style: AppTextStyles.bodyMedium(textColor)),
                      ),
                      Text('₹ 2,400', style: AppTextStyles.labelMedium(textColor)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Send Payment Reminder',
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Reminder sent to customer')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelMedium(AppColors.textPrimary)),
      ],
    );
  }
}
