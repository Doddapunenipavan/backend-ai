import 'package:flutter/material.dart';

/// App-wide theme mode controller.
///
/// Kept intentionally simple (a single [ValueNotifier], no state
/// management package) since nothing else in this app needs shared state
/// yet. [MerchantApp] listens to this via [ValueListenableBuilder] and the
/// Settings screen's "Dark Mode" switch reads/writes it directly — so the
/// switch actually changes the theme instead of just flipping local state.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static void setDarkMode(bool isDark) {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDarkMode => mode.value == ThemeMode.dark;
}
