import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/screens/auth/login_screen.dart';
import 'package:quickcng/screens/admin/admin_dashboard_screen.dart';
import 'package:quickcng/screens/owner/owner_dashboard_screen.dart';
import 'package:quickcng/screens/spalsh_screen.dart';

import '../models/enums.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/error_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/station_detail/station_detail_screen.dart';
import '../screens/verification_form_screen.dart';
import '../screens/auth/setup_profile_screen.dart';
import '../screens/profile/pages/help_faq_screen.dart';
import '../screens/profile/pages/send_feedback_screen.dart';
import '../screens/profile/pages/about_app_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _GoRouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', name: 'auth', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/setup', name: 'setup', builder: (context, state) => const SetupProfileScreen()),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/station/:id', name: 'details', builder: (context, state) {
        final stationId = state.pathParameters['id']!;
        return StationDetailScreen(stationId: stationId);
      }),
      GoRoute(path: '/report', name: 'report', builder: (context, state) {
        final station = state.extra as Station?;
        if (station == null) return const ErrorScreen(error: 'Station missing', path: '/report');
        return ReportScreen(station: station);
      }),
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/verification', name: 'verification', builder: (context, state) => const VerificationFormScreen()),
      GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const OwnerDashboardScreen()),
      GoRoute(path: '/admin', name: 'admin', builder: (context, state) => const AdminDashboardScreen()),
      
      // Support Pages
      GoRoute(path: '/help', name: 'help', builder: (context, state) => const HelpFaqScreen()),
      GoRoute(path: '/feedback', name: 'feedback', builder: (context, state) => const SendFeedbackScreen()),
      GoRoute(path: '/about', name: 'about', builder: (context, state) => const AboutAppScreen()),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString() ?? 'Unknown error',
      path: state.uri.toString(),
    ),
    redirect: (context, state) {
      final location = state.uri.toString();
      final isGoingToAuth = location == '/auth';
      final isGoingToSetup = location == '/setup';

      // 1. Auth Gate (Async lookup)
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) return null;

      final user = authState.value;
      if (user == null) {
        return isGoingToAuth || location == '/' ? null : '/auth';
      }

      // 2. Profile Check (Firestore Doc Exists - Async lookup)
      final profileState = ref.read(userProfileProvider);

      if (profileState.isLoading) return null;

      final profile = profileState.value;
      
      // IF logged in to Google but NO document exists -> send straight to setup.
      if (profile == null) {
        return isGoingToSetup || location == '/' ? null : '/setup';
      }

      // 3. User Document Exists -> Route them by Role
      if (location == '/' || location == '/auth' || location == '/setup' || location == '/verification') {
        switch (profile.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.owner:
            return '/dashboard';
          case UserRole.worker:
          case UserRole.user:
          case UserRole.guest:
            return '/home';
        }
      }

      return null;
    },
  );
});

class _GoRouterNotifier extends ChangeNotifier {
  _GoRouterNotifier(Ref ref) {
    ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<AsyncValue<dynamic>>(
      userProfileProvider,
      (_, __) => notifyListeners(),
    );
  }
}