import 'package:flutter/material.dart';

/// FlexTenure Merchant brand color palette — matches the FlexTenure
/// customer app exactly so the two apps feel like one product family.
///
/// Brand rule: blue is the hero color (logo gradient). Green is intentionally
/// excluded from the primary/accent palette — use [success] sparingly and
/// never as a theme or brand color.
class AppColors {
  AppColors._();

  // ---- Brand Gradient ----
  static const Color gradientStart = Color(0xFF00B8F5);
  static const Color gradientEnd = Color(0xFF0A66FF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---- Core Brand ----
  static const Color primary = Color(0xFF0A66FF);
  static const Color primaryLight = Color(0xFF00B8F5);
  static const Color primarySurface = Color(0xFFEAF6FF); // tinted bg for chips/icons

  // ---- Light Theme Surfaces ----
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8FAFC); // subtle off-white for grouped sections

  // ---- Dark Theme Surfaces ----
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF141B2D);
  static const Color surfaceAltDark = Color(0xFF1B2333);

  // ---- Text ----
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF5F7FA);
  static const Color textSecondaryDark = Color(0xFF9AA4B2);

  // ---- Borders / Dividers ----
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF293044);

  // ---- Status (kept minimal — brand stays blue-led) ----
  static const Color success = Color(0xFF12B76A); // status dots/text only
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ---- Shadows ----
  static const Color shadow = Color(0x1A0A66FF); // soft blue-tinted shadow for elevation
}
