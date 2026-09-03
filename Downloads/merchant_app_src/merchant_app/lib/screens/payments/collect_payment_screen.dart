import 'package:flutter/material.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/text_fields/app_text_field.dart';

class CollectPaymentScreen extends StatefulWidget {
  const CollectPaymentScreen({super.key});

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  bool _isLoading = false;
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  void _collect() {
    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount to collect.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final customer = _customerController.text.trim();
      final amount = _amountController.text.trim();
      // Fires instantly to every screen via the live toast banner, and lands
      // in the Notification Center feed — this is the real-time delivery
      // path described in NotificationService.
      NotificationService.instance.push(
        title: 'Payment received',
        message:
            '₹$amount collected${customer.isEmpty ? '' : ' from $customer'}.',
        type: AppNotificationType.payment,
      );
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Collect Payment', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md - 2),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded,
                          size: 120, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Ask customer to scan to pay',
                      style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or enter manually',
                      style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Customer',
              hint: 'Search by name or phone',
              prefixIcon: Icons.person_outline_rounded,
              controller: _customerController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount',
              hint: '₹ 0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.currency_rupee_rounded,
              controller: _amountController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Note (optional)',
              hint: 'e.g. EMI #5',
              prefixIcon: Icons.notes_rounded,
              controller: _noteController,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
                label: 'Confirm Collection',
                isLoading: _isLoading,
                onPressed: _collect),
          ],
        ),
      ),
    );
  }
}
