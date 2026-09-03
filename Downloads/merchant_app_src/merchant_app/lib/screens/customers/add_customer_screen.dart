import 'package:flutter/material.dart';
import '../../core/animations/app_animations.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/text_fields/app_text_field.dart';

/// Add Customer screen — previously this didn't exist at all: the "+" icon
/// on the Customers screen and the "Add Customer" quick action on the
/// Dashboard both had empty `onPressed`/routed nowhere useful, so tapping
/// them did nothing. This screen mirrors the same pattern already used by
/// Add Product / Register so the app is visually consistent.
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final name = _nameController.text.trim();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$name added as a new customer')));
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Customer', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: staggeredChildren([
                AppTextField(
                  label: 'Full Name',
                  hint: 'e.g. Rahul Mehta',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone Number',
                  hint: '10-digit mobile number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.call_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid number' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email (optional)',
                  hint: 'customer@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Product Purchased',
                  hint: 'e.g. Samsung Galaxy S23',
                  prefixIcon: Icons.inventory_2_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Total Amount (₹)',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Tenure (months)',
                  hint: 'e.g. 12',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_month_outlined,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Add Customer', isLoading: _isLoading, onPressed: _save),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
