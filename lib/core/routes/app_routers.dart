import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/dashboard/screens/dashboard_screen.dart';
import 'package:cravvy_cooking_app/modules/splash/screens/splash_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/onboarding_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/goal_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/diet_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/setup_complete_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/login/screen/login_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/register/screen/register_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/screen/forgot_password_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/screen/otp_screen.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/screens/meal_detail_screen.dart';
import 'package:cravvy_cooking_app/modules/profile/screen/edit_profile_screen.dart';
import 'package:cravvy_cooking_app/modules/premium/screen/premium_screen.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';

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
  static const String mealPlan = app;

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String otp = '/auth/otp';
  static const String mealDetail = '/meal-detail';
  static const String editProfile = '/profile/edit';
  static const String premium = '/premium';

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
          child: const DashboardScreen(),
        ),
      ),

      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final email = (state.extra as String?) ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: mealDetail,
        builder: (context, state) {
          final meal = state.extra as Meal;
          return MealDetailScreen(meal: meal);
        },
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: premium,
        builder: (context, state) => const PremiumScreen(),
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
