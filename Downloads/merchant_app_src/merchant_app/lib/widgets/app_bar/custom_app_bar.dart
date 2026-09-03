import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Standard app bar — clean, flat, with optional back button, title,
/// and trailing actions. Keeps every screen's header visually consistent.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.onBack,
    this.centerTitle = false,
  });

  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).appBarTheme.foregroundColor ?? AppColors.textPrimary;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      titleSpacing: showBackButton ? 0 : 20,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.primary,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(title, style: AppTextStyles.h4(textColor)),
      actions: actions != null
          ? [...actions!, const SizedBox(width: 8)]
          : null,
    );
  }
}
