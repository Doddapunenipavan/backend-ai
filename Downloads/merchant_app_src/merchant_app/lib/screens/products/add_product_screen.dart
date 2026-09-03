import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/text_fields/app_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool _isLoading = false;

  void _save() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Product', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(height: 8),
                  Text('Add product photo', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Product Name',
              hint: 'e.g. Samsung Galaxy S23',
              prefixIcon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Price (₹)',
              hint: '0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.currency_rupee_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Tenure Options (months)',
              hint: 'e.g. 6, 9, 12',
              prefixIcon: Icons.calendar_month_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Category',
              hint: 'e.g. Electronics',
              prefixIcon: Icons.category_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description (optional)',
              hint: 'Brief details about the product',
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Save Product', isLoading: _isLoading, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
