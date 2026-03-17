import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cravvy_cooking_app/modules/splash/screen/splash_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screen/onboarding_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screen/goal_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screen/diet_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screen/setup_complete_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/main_shell.dart';

/// Arguments passed from [GoalSelectionScreen] / [DietSelectionScreen]
/// to [SetupCompleteScreen].
class OnboardingArgs {
  final HealthGoal? goal;
  final Set<DietType> diets;

  const OnboardingArgs({this.goal, required this.diets});
}

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String goalSelection = '/onboarding/goal';
  static const String dietSelection = '/onboarding/diet';
  static const String setupComplete = '/onboarding/complete';
  static const String app = '/app';

  /// Alias kept for backward-compatibility with screens that use [mealPlan].
  static const String mealPlan = app;

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
      GoRoute(
        path: goalSelection,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
          child: const GoalSelectionScreen(),
        ),
      ),
      GoRoute(
        path: dietSelection,
        builder: (context, state) {
          final goal = state.extra as HealthGoal?;
          return ChangeNotifierProvider(
            create: (_) {
              final provider = OnboardingProvider();
              if (goal != null) provider.selectGoal(goal);
              return provider;
            },
            child: const DietSelectionScreen(),
          );
        },
      ),
      GoRoute(
        path: setupComplete,
        builder: (context, state) {
          final args = state.extra as OnboardingArgs;
          return SetupCompleteScreen(args: args);
        },
      ),
      GoRoute(
        path: app,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => MealPlanProvider(),
          child: const MainShell(),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}

class _AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    assert(() {
      debugPrint('📌 Push: ${route.settings.name}');
      return true;
    }());
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    assert(() {
      debugPrint('⬅️  Pop: ${route.settings.name}');
      return true;
    }());
  }
}
