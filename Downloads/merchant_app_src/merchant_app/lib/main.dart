import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'widgets/notifications/notification_banner.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'FlexTenure Merchant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: appRouter,
          // Wraps every screen so a live toast can slide down the instant
          // NotificationService.instance.push(...) is called anywhere in the
          // app — this is the "real-time notification" delivery layer.
          builder: (context, child) => NotificationBannerHost(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
