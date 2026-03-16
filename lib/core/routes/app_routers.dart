import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String goalSelection = '/onboarding/goal';
  static const String dietSelection = '/onboarding/diet';
  static const String setupComplete = '/onboarding/complete';
  static const String app = '/app';

  static void _logRoute(String? name) {
    assert(() {
      debugPrint('🧭 Navigate → $name');
      return true;
    }());
  }

  static final GoRouter router = GoRouter(
    initialLocation: splash,

    observers: [_AppRouteObserver()],

    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) {
          _logRoute(state.fullPath);
          return const NoTransitionPage(child: SplashScreen());
        },
      ),

      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ✅ DI tại route — OnboardingProvider chỉ sống trong flow onboarding
      GoRoute(
        path: goalSelection,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => OnboardingProvider(), // tạo mới, tự dispose khi pop
          child: const GoalSelectionScreen(),
        ),
      ),

      GoRoute(
        path: dietSelection,
        // ✅ Nhận argument từ route trước
        builder: (context, state) {
          final goal = state.extra as HealthGoal?;
          return ChangeNotifierProvider(
            create: (_) => OnboardingProvider()..selectGoal(goal),
            child: const DietSelectionScreen(),
          );
        },
      ),

      GoRoute(
        path: setupComplete,
        builder: (context, state) {
          // ✅ Type-safe argument — học từ settings.arguments
          final args = state.extra as OnboardingArgs;
          return SetupCompleteScreen(args: args);
        },
      ),

      // ✅ MealPlanProvider chỉ sống trong /app, không phải global
      GoRoute(
        path: app,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => MealPlanProvider(),
          child: const MainShell(),
        ),
      ),
    ],

    // errorBuilder: (context, state) => _ErrorScreen(path: state.uri.toString()),
  );
}
