import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Professional typography hierarchy for FlexTenure Merchant.
/// Uses Inter — same as the customer app — for a consistent,
/// enterprise-grade fintech feel across the product family.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ---- Display / Headings ----
  static TextStyle h1(Color color) => _base(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle h2(Color color) => _base(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle h3(Color color) => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h4(Color color) => _base(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  // ---- Body ----
  static TextStyle bodyLarge(Color color) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium(Color color) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall(Color color) => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  // ---- Labels / Buttons ----
  static TextStyle labelLarge(Color color) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(Color color) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle caption(Color color) => _base(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.2,
      );

  // ---- Convenience presets bound to brand text colors ----
  static TextStyle get h1Primary => h1(AppColors.textPrimary);
  static TextStyle get h2Primary => h2(AppColors.textPrimary);
  static TextStyle get h3Primary => h3(AppColors.textPrimary);
  static TextStyle get bodyPrimary => bodyMedium(AppColors.textPrimary);
  static TextStyle get bodySecondary => bodyMedium(AppColors.textSecondary);
}
