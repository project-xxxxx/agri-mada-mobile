import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/settings_screen.dart';
import '../features/guides/presentation/screens/guides_screen.dart';
import '../features/prevention/presentation/screens/prevention_screen.dart';
import '../features/scan/presentation/screens/organ_picker_screen.dart';
import '../features/scan/presentation/screens/capture_screen.dart';
import '../features/scan/presentation/screens/scan_questions_screen.dart';
import '../features/scan/presentation/screens/session_result_screen.dart';
import '../features/journal/presentation/screens/journal_screen.dart';
import '../features/journal/presentation/screens/my_parcelles_screen.dart';
import '../features/journal/presentation/screens/parcelle_detail_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../core/local_db/session_service.dart';
import '../core/widgets/main_layout.dart';
import 'package:flutter/material.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String reset = '/reset';
  static const String home = '/home';
  static const String settings = '/settings';
  /// Parcours de scan multi-organes (phase P2).
  static const String scanOrgane = '/scan/organe';
  static const String scanCapture = '/scan/capture';
  static const String scanQuestions = '/scan/questions';
  static const String scanSessionResult = '/scan/resultat';
  static const String journal = '/journal';
  static const String myParcelles = '/my-parcelles';
  static const String parcelleDetail = '/parcelle/:id';
  static const String prevention = '/prevention';
  static const String guides = '/guides';
  static const String onboarding = '/onboarding';
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.keepAlive();
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      final results = await Future.wait([
        SessionService.instance.isOnboardingDone(),
        SessionService.instance.isLoggedIn(),
      ]);
      final isOnboardingDone = results[0];
      final isLoggedIn = results[1];
      final route = state.matchedLocation;
      final isSplashRoute = route == AppRoutes.splash;
      final isAuthRoute = route == AppRoutes.welcome ||
          route == AppRoutes.login ||
          route == AppRoutes.register ||
          route == AppRoutes.reset;
      final isProtectedRoute = route == AppRoutes.home ||
          route == AppRoutes.settings ||
          route == AppRoutes.scanOrgane ||
          route == AppRoutes.scanCapture ||
          route == AppRoutes.scanQuestions ||
          route == AppRoutes.scanSessionResult ||
          route == AppRoutes.journal ||
          route == AppRoutes.myParcelles;
      final isOnboardingConsultationMode =
          state.uri.queryParameters['mode'] == 'help';

      if (!isOnboardingDone && route != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (isOnboardingDone &&
          route == AppRoutes.onboarding &&
          !isOnboardingConsultationMode) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.welcome;
      }

      if (!isLoggedIn && isProtectedRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && (isSplashRoute || isAuthRoute)) {
        return AppRoutes.home;
      }

      if (!isLoggedIn && isSplashRoute) {
        return AppRoutes.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.reset,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const JournalScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.myParcelles,
        builder: (context, state) => const MyParcellesScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelleDetail,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ParcelleDetailScreen(
            parcelleId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanOrgane,
        builder: (context, state) {
          final parcelleIdParam = state.uri.queryParameters['parcelleId'];
          return OrganPickerScreen(
            parcelleLocalId:
                parcelleIdParam != null ? int.tryParse(parcelleIdParam) : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.scanCapture,
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanQuestions,
        builder: (context, state) => const ScanQuestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanSessionResult,
        builder: (context, state) => const SessionResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.prevention,
        builder: (context, state) => const PreventionScreen(),
      ),
      GoRoute(
        path: AppRoutes.guides,
        builder: (context, state) => const GuidesScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          consultationMode: state.uri.queryParameters['mode'] == 'help',
        ),
      ),
    ],
  );
});
