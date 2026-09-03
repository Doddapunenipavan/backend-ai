import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static final _faqs = <_Faq>[
    _Faq('How long does settlement take?',
        'Settlements are processed on a T+1 business day cycle after each transaction.'),
    _Faq('How do I add a new product?',
        'Go to Dashboard → Products → Add Product, then fill in details and save.'),
    _Faq('How do I update my bank account?',
        'Go to Profile → Bank & Settlement → Add Bank Account.'),
    _Faq('Is my data secure?',
        'Yes, all data is encrypted in transit and at rest, and you can enable 2FA under Security.'),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Help Center'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                    child: const Icon(Icons.support_agent_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need help?',
                            style: AppTextStyles.bodyMedium(textColor)),
                        const SizedBox(height: 4),
                        Text('Our team replies within 24 hours',
                            style: AppTextStyles.bodySmall(
                                AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Frequently Asked Questions',
                style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(_faqs.length, (i) {
                  final faq = _faqs[i];
                  return Column(
                    children: [
                      ExpansionTile(
                        iconColor: AppColors.primary,
                        collapsedIconColor: AppColors.textSecondary,
                        title: Text(faq.question,
                            style: AppTextStyles.bodyMedium(textColor)),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(faq.answer,
                              style: AppTextStyles.bodySmall(
                                  AppColors.textSecondary)),
                        ],
                      ),
                      if (i != _faqs.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@flextenure.com',
                    query: 'subject=${Uri.encodeComponent("Support request")}',
                  );
                  final ok = await launchUrl(uri);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                          content: Text('Couldn\'t open your email app. Reach us at support@flextenure.com')));
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Contact Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}
