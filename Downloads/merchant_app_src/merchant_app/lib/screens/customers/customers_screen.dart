import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/cards/app_card.dart';

class _Customer {
  const _Customer(
      this.id, this.name, this.product, this.amount, this.status, this.type);
  final String id;
  final String name;
  final String product;
  final String amount;
  final String status;
  final StatusChipType type;
}

const _customers = [
  _Customer('1', 'Rahul Mehta', 'Samsung S23 · EMI 4/12', '₹ 2,400 / mo',
      'On Track', StatusChipType.success),
  _Customer('2', 'Priya Patel', 'iPhone 14 · EMI 1/10', '₹ 4,200 / mo', 'New',
      StatusChipType.neutral),
  _Customer('3', 'Aman Joshi', 'LG Fridge · EMI 2/6', '₹ 1,850 / mo',
      'On Track', StatusChipType.success),
  _Customer('4', 'Kiran Rao', 'OnePlus 12 · EMI 6/12', '₹ 3,200 / mo',
      'Overdue', StatusChipType.error),
  _Customer('5', 'Neha Shah', 'Sofa Set · EMI 3/8', '₹ 2,750 / mo', 'Due Soon',
      StatusChipType.warning),
];

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Customer> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.product.toLowerCase().contains(q) ||
          c.status.toLowerCase().contains(q) ||
          c.amount.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;
    final results = _filtered;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Customers',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.primary),
            onPressed: () => context.push('/customers/add'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.shadow.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search customers',
                          hintStyle:
                              AppTextStyles.bodyMedium(AppColors.textSecondary),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _searchController.clear();
                          _query = '';
                        }),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? _EmptyState(query: _query)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final c = results[index];
                        return AppCard(
                          onTap: () => context.push('/customers/${c.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  c.name.substring(0, 1),
                                  style: AppTextStyles.labelLarge(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name,
                                        style: AppTextStyles.labelMedium(
                                            textColor)),
                                    const SizedBox(height: 2),
                                    Text(c.product,
                                        style: AppTextStyles.bodySmall(
                                            AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(c.amount,
                                      style:
                                          AppTextStyles.labelMedium(textColor)),
                                  const SizedBox(height: 6),
                                  StatusChip(label: c.status, status: c.type),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No customers found', style: AppTextStyles.h4(textColor)),
            const SizedBox(height: 6),
            Text(
              'Nothing matches "$query". Try a different name or product.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
