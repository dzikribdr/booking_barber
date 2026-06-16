import 'package:go_router/go_router.dart';
import '../../core/widgets/scaffold_with_nav_bar.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_register_page.dart';
import '../../features/customer_home/presentation/pages/customer_home_page.dart';
import '../../features/barber_dashboard/presentation/pages/barber_dashboard_page.dart';
import '../../features/services/presentation/pages/signature_services_catalog_page.dart';
import '../../features/booking/presentation/pages/booking_selection_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/queue/presentation/pages/queue_tracking_page.dart';
import '../../features/admin/presentation/pages/super_admin_dashboard_page.dart';
import '../../features/services/presentation/pages/shave_services_page.dart';
import '../../features/services/presentation/pages/hair_treatments_page.dart';
import '../../features/services/presentation/pages/haircut_styles_page.dart';
import '../../features/services/presentation/pages/beard_trim_page.dart';
import '../../features/booking/presentation/pages/booking_history_page.dart';
import '../../features/profile/presentation/pages/profile_settings_page.dart';

import '../../features/profile/presentation/pages/style_vault_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginRegisterPage(),
      ),
      
      // Bottom Navigation Bar Routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const CustomerHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking',
                builder: (context, state) => const BookingSelectionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/queue',
                builder: (context, state) => const QueueTrackingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileSettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Other Top-Level Routes (No Navbar)
      GoRoute(
        path: '/barber-dashboard',
        builder: (context, state) => const BarberDashboardPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const SignatureServicesCatalogPage(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const SuperAdminDashboardPage(),
      ),
      GoRoute(
        path: '/shave',
        builder: (context, state) => const ShaveServicesPage(),
      ),
      GoRoute(
        path: '/treatments',
        builder: (context, state) => const HairTreatmentsPage(),
      ),
      GoRoute(
        path: '/haircuts',
        builder: (context, state) => const HaircutStylesPage(),
      ),
      GoRoute(
        path: '/beard-trim',
        builder: (context, state) => const BeardTrimPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          final status = state.uri.queryParameters['status'];
          return BookingHistoryPage(statusFilter: status);
        },
      ),
      GoRoute(
        path: '/style-vault',
        builder: (context, state) => const StyleVaultPage(),
      ),
    ],
  );
}




