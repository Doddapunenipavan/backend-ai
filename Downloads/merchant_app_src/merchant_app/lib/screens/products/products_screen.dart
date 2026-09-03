import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class _Product {
  const _Product(this.name, this.price, this.emi, this.icon);
  final String name;
  final String price;
  final String emi;
  final IconData icon;
}

const _products = [
  _Product('Samsung Galaxy S23', '₹ 54,999', 'from ₹ 2,400/mo', Icons.smartphone_rounded),
  _Product('LG 260L Refrigerator', '₹ 26,500', 'from ₹ 1,850/mo', Icons.kitchen_rounded),
  _Product('Sofa Set (3+2)', '₹ 32,000', 'from ₹ 2,750/mo', Icons.weekend_rounded),
  _Product('OnePlus 12', '₹ 64,999', 'from ₹ 3,200/mo', Icons.smartphone_rounded),
];

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => context.push('/dashboard/products/add'),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final p = _products[index];
            return AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primarySurface, AppColors.primarySurface.withOpacity(0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(p.icon, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 10),
                  Text(p.name, style: AppTextStyles.labelMedium(textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(p.price, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                  const Spacer(),
                  Text(p.emi, style: AppTextStyles.caption(AppColors.primary)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
