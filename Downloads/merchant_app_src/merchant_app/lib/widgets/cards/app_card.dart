import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Generic content card — white surface, soft shadow, 16px corners,
/// subtle press animation when tappable.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: _pressed ? 8 : 18,
              offset: Offset(0, _pressed ? 2 : 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: card),
    );
  }
}

/// Fintech-style KPI / statistic card for dashboard grids — value, label,
/// trend delta pill, and a tinted gradient icon badge in brand blue.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.deltaLabel,
    this.isPositiveDelta = true,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? deltaLabel;
  final bool isPositiveDelta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;
    final secondaryColor =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final deltaColor = isPositiveDelta ? AppColors.success : AppColors.error;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall(secondaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySurface,
                        AppColors.primarySurface.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTextStyles.h3(textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (deltaLabel != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: deltaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositiveDelta
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 13,
                    color: deltaColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      deltaLabel!,
                      style: AppTextStyles.caption(deltaColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Elevated gradient variant of [KpiCard] — use sparingly for the single
/// "hero" metric on a screen (e.g. This Month's Collections).
class GradientStatCard extends StatelessWidget {
  const GradientStatCard({
    super.key,
    required this.label,
    required this.value,
    this.deltaLabel,
    this.isPositiveDelta = true,
    this.icon,
  });

  final String label;
  final String value;
  final String? deltaLabel;
  final bool isPositiveDelta;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientEnd.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodySmall(
                        Colors.white.withOpacity(0.85))),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.h1(Colors.white)),
          if (deltaLabel != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isPositiveDelta
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    deltaLabel!,
                    style: AppTextStyles.caption(Colors.white.withOpacity(0.9)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Small pill-shaped status indicator (e.g. Active, Pending, Overdue,
/// Completed). Uses tinted backgrounds with a dot accent so it reads
/// clearly without competing with the brand blue.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.status});

  final String label;
  final StatusChipType status;

  Color get _color {
    switch (status) {
      case StatusChipType.success:
        return AppColors.success;
      case StatusChipType.warning:
        return AppColors.warning;
      case StatusChipType.error:
        return AppColors.error;
      case StatusChipType.neutral:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption(color)),
        ],
      ),
    );
  }
}

enum StatusChipType { success, warning, error, neutral }
