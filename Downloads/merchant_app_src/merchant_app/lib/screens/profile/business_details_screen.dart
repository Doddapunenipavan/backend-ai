import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    final details = <_DetailRow>[
      _DetailRow('Business Name', 'Sharma Electronics'),
      _DetailRow('Merchant ID', 'FT-MER-1042'),
      _DetailRow('Business Type', 'Retail — Electronics'),
      _DetailRow('GSTIN', '24ABCDE1234F1Z5'),
      _DetailRow('PAN', 'ABCDE1234F'),
      _DetailRow(
          'Registered Address', 'Shop 12, Ring Road, Rajkot, Gujarat - 360001'),
      _DetailRow('Contact Number', '+91 98765 43210'),
      _DetailRow('Email', 'sharma.electronics@example.com'),
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Business Details'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(details.length, (i) {
                  final d = details[i];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(d.label,
                                  style: AppTextStyles.bodySmall(
                                      AppColors.textSecondary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(d.value,
                                  style: AppTextStyles.bodyMedium(textColor)),
                            ),
                          ],
                        ),
                      ),
                      if (i != details.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                        content: Text('Edit request submitted for review')));
                },
                child: const Text('Request Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
}
