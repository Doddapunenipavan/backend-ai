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

class _BankAccount {
  _BankAccount(this.bankName, this.accountLast4, {this.verified = true});
  final String bankName;
  final String accountLast4;
  final bool verified;
}

class BankSettlementScreen extends StatefulWidget {
  const BankSettlementScreen({super.key});

  @override
  State<BankSettlementScreen> createState() => _BankSettlementScreenState();
}

class _BankSettlementScreenState extends State<BankSettlementScreen> {
  final List<_BankAccount> _accounts = [_BankAccount('HDFC Bank', '4821')];

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Bank & Settlement'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final account in _accounts) ...[
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.account_balance_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.bankName,
                              style: AppTextStyles.bodyMedium(textColor)),
                          const SizedBox(height: 4),
                          Text('A/C ending •• ${account.accountLast4}',
                              style: AppTextStyles.bodySmall(
                                  AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (account.verified ? AppColors.success : AppColors.warning)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(account.verified ? 'Verified' : 'Pending',
                          style: AppTextStyles.caption(
                              account.verified ? AppColors.success : AppColors.warning)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Settlement Cycle', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.schedule_rounded,
                        color: AppColors.primary),
                    title: Text('Payout Frequency',
                        style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('T+1 business day',
                        style:
                            AppTextStyles.bodySmall(AppColors.textSecondary)),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.currency_rupee_rounded,
                        color: AppColors.primary),
                    title: Text('Next Settlement',
                        style: AppTextStyles.bodyMedium(textColor)),
                    subtitle: Text('₹24,560 — Tomorrow, 10:00 AM',
                        style:
                            AppTextStyles.bodySmall(AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddBankAccountSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Bank Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBankAccountSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final holderController = TextEditingController();
    final accountController = TextEditingController();
    final ifscController = TextEditingController();
    final bankNameController = TextEditingController();
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
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                ),
                child: SingleChildScrollView(
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
                        Text('Add Bank Account',
                            style: AppTextStyles.h4(
                                Theme.of(sheetContext).textTheme.bodyMedium?.color ??
                                    AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Account Holder Name',
                          hint: 'As per bank records',
                          controller: holderController,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter the account holder name' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Bank Name',
                          hint: 'e.g. ICICI Bank',
                          controller: bankNameController,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter the bank name' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Account Number',
                          hint: 'Enter account number',
                          controller: accountController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter the account number';
                            if (v.trim().length < 6) return 'Account number looks too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'IFSC Code',
                          hint: 'e.g. HDFC0001234',
                          controller: ifscController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter the IFSC code';
                            if (v.trim().length != 11) return 'IFSC code must be 11 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Add Account',
                          isLoading: submitting,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            setSheetState(() => submitting = true);
                            await Future.delayed(const Duration(milliseconds: 700));
                            if (!sheetContext.mounted) return;

                            final acctNumber = accountController.text.trim();
                            final last4 = acctNumber.length >= 4
                                ? acctNumber.substring(acctNumber.length - 4)
                                : acctNumber;

                            Navigator.of(sheetContext).pop();

                            setState(() {
                              _accounts.add(
                                _BankAccount(bankNameController.text.trim(), last4, verified: false),
                              );
                            });

                            NotificationService.instance.push(
                              title: 'Bank account added',
                              message:
                                  '${bankNameController.text.trim()} account ending $last4 is pending verification.',
                              type: AppNotificationType.settlement,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                    content: Text('Bank account added — pending verification')));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
