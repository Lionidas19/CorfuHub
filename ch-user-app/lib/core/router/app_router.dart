import 'package:go_router/go_router.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/screens/debug_user_picker_screen.dart';
import '../../features/auth/screens/phone_login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/map/screens/place_detail_screen.dart';
import '../../features/map/screens/search_screen.dart';
import '../../features/issues/screens/issues_map_screen.dart';
import '../../features/issues/screens/report_issue_screen.dart';
import '../../features/issues/screens/issue_detail_screen.dart';
import '../../features/check_ins/screens/check_in_confirm_screen.dart';
import '../../features/check_ins/screens/check_in_history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/saved_places_screen.dart';
import '../../features/profile/screens/home_pin_screen.dart';
import '../../features/profile/screens/trust_info_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import 'app_shell.dart';
import 'package:corfu_shared/shared.dart';

GoRouter buildRouter(AuthNotifier authNotifier) {
  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/map',
    redirect: (context, state) {
      final status = authNotifier.status;
      final isAuth = status == AuthStatus.authenticated;
      final isUnknown = status == AuthStatus.unknown;
      final onAuth = state.uri.toString().startsWith('/auth');

      if (isUnknown) return null; // wait
      if (!isAuth && !onAuth) return '/auth';
      if (isAuth && onAuth) return '/map';
      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: '/auth',
        builder: (_, __) => const DebugUserPickerScreen(),
        routes: [
          GoRoute(
            path: 'phone',
            builder: (_, __) => const PhoneLoginScreen(),
            routes: [
              GoRoute(
                path: 'verify',
                builder: (_, state) => OtpVerifyScreen(
                  phone: (state.extra as String?) ?? '',
                ),
              ),
            ],
          ),
        ],
      ),

      // Shell with bottom nav
      ShellRoute(
        builder: (_, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/map',
            builder: (_, __) => const MapScreen(),
          ),
          GoRoute(
            path: '/issues',
            builder: (_, __) => const IssuesMapScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen routes (no shell)
      GoRoute(
        path: '/place/:id',
        builder: (_, state) => PlaceDetailScreen(
          placeId: state.pathParameters['id']!,
          place: state.extra as PlaceEntity?,
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/issues/report',
        builder: (_, __) => const ReportIssueScreen(),
      ),
      GoRoute(
        path: '/issues/:id',
        builder: (_, state) => IssueDetailScreen(
          issueId: state.pathParameters['id']!,
          issue: state.extra as IssueEntity?,
        ),
      ),
      GoRoute(
        path: '/check-ins/confirm',
        builder: (_, state) {
          final extra = state.extra as Map<String, String?>?;
          return CheckInConfirmScreen(
            placeId: extra?['placeId'],
            placeName: extra?['placeName'],
          );
        },
      ),
      GoRoute(
        path: '/check-ins/history',
        builder: (_, __) => const CheckInHistoryScreen(),
      ),
      GoRoute(
        path: '/profile/saved',
        builder: (_, __) => const SavedPlacesScreen(),
      ),
      GoRoute(
        path: '/profile/home-pin',
        builder: (_, __) => const HomePinScreen(),
      ),
      GoRoute(
        path: '/profile/trust-info',
        builder: (_, __) => const TrustInfoScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
}
