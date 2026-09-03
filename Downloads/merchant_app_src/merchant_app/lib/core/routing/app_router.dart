import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav/app_bottom_nav.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/customers/customers_screen.dart';
import '../../screens/customers/customer_detail_screen.dart';
import '../../screens/customers/add_customer_screen.dart';
import '../../screens/payments/payments_screen.dart';
import '../../screens/payments/collect_payment_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/business_details_screen.dart';
import '../../screens/profile/bank_settlement_screen.dart';
import '../../screens/profile/notifications_screen.dart';
import '../../screens/profile/security_screen.dart';
import '../../screens/profile/help_center_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/products/add_product_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/onboarding/onboarding_flow_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _shellDashboardKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
final GlobalKey<NavigatorState> _shellCustomersKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellCustomers');
final GlobalKey<NavigatorState> _shellPaymentsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellPayments');
final GlobalKey<NavigatorState> _shellProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // ---------- Root-level (no bottom nav) ----------
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const OnboardingFlowScreen(),
    ),

    // ---------- Bottom-nav shell ----------
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppBottomNavScaffold(navigationShell: navigationShell),
      branches: [
        // Tab 1 — Dashboard
        StatefulShellBranch(
          navigatorKey: _shellDashboardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'products',
                  builder: (context, state) => const ProductsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddProductScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'transactions',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),
          ],
        ),

        // Tab 2 — Customers
        StatefulShellBranch(
          navigatorKey: _shellCustomersKey,
          routes: [
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddCustomerScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    if (id == null || id.isEmpty) {
                      return const _MissingParamScreen(param: 'customer id');
                    }
                    return CustomerDetailScreen(customerId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 3 — Payments
        StatefulShellBranch(
          navigatorKey: _shellPaymentsKey,
          routes: [
            GoRoute(
              path: '/payments',
              builder: (context, state) => const PaymentsScreen(),
              routes: [
                GoRoute(
                  path: 'collect',
                  builder: (context, state) => const CollectPaymentScreen(),
                ),
              ],
            ),
          ],
        ),

        // Tab 4 — Profile
        StatefulShellBranch(
          navigatorKey: _shellProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'business-details',
                  builder: (context, state) => const BusinessDetailsScreen(),
                ),
                GoRoute(
                  path: 'bank-settlement',
                  builder: (context, state) => const BankSettlementScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecurityScreen(),
                ),
                GoRoute(
                  path: 'help-center',
                  builder: (context, state) => const HelpCenterScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => _RouteErrorScreen(error: state.error),
);

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                error?.toString() ?? 'The page you requested does not exist.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingParamScreen extends StatelessWidget {
  const _MissingParamScreen({required this.param});
  final String param;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invalid link')),
      body: Center(child: Text('Missing required parameter: $param')),
    );
  }
}
