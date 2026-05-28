import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/dashboard/screens/dashboard_screen.dart';
import 'package:cravvy_cooking_app/modules/splash/screens/splash_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/onboarding_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/goal_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/diet_selection_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/setup_complete_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/setup/setup_screen.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/login/screen/login_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/register/screen/register_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/screen/forgot_password_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/screen/otp_screen.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/screen/reset_password_screen.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/screens/meal_detail_screen.dart';
import 'package:cravvy_cooking_app/modules/cooking_mode/screen/cooking_mode_screen.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/screen/shopping_list_screen.dart';
import 'package:cravvy_cooking_app/modules/settings/screen/settings_screen.dart';
import 'package:cravvy_cooking_app/modules/subscription/screen/subscription_screen.dart';
import 'package:cravvy_cooking_app/modules/trial/screen/trial_activation_screen.dart';
import 'package:cravvy_cooking_app/modules/faq/screen/faq_screen.dart';
import 'package:cravvy_cooking_app/modules/legal/screen/legal_screen.dart';
import 'package:cravvy_cooking_app/modules/profile/screen/edit_profile_screen.dart';
import 'package:cravvy_cooking_app/modules/premium/screen/premium_screen.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';

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

  static const String setupStep1 = '/setup/1';
  static const String setupStep2 = '/setup/2';
  static const String setupStep3 = '/setup/3';
  static const String setupStep4 = '/setup/4';
  static const String setupStep5 = '/setup/5';
  static const String app = '/app';
  static const String mealPlan = app;
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String otp = '/auth/otp';
  static const String resetPassword = '/auth/reset-password';
  // Features
  static const String mealDetail = '/meal-detail';
  static const String cookingMode = '/cooking';
  static const String editProfile = '/profile/edit';
  static const String premium = '/premium';
  static const String subscription = '/subscription';
  static const String trialActivation = '/trial-success';
  static const String shoppingList = '/shopping-list';
  static const String settings = '/settings';
  static const String faq = '/faq';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String disclaimer = '/disclaimer';

  static const List<String> _setupRoutes = [
    setupStep1, setupStep2, setupStep3, setupStep4, setupStep5, setupComplete,
  ];

  static const List<String> _publicRoutes = [
    splash, login, register, forgotPassword, otp, resetPassword,
    onboarding, goalSelection, dietSelection,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final location = state.matchedLocation;

      if (auth.status == AuthStatus.initial) {
        return location == splash ? null : splash;
      }

      final isPublic = _publicRoutes.contains(location);
      final isSetup = _setupRoutes.contains(location);

      if (!auth.isLoggedIn && !isPublic && !isSetup) {
        if (isSetup) return login;
        return login;
      }

      if (auth.isLoggedIn && (location == login || location == register)) {
        if (auth.user?.onboardingComplete == true) return app;
        return setupStep1;
      }

      return null; // không redirect
    },
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
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
        builder: (context, state) =>
            SetupCompleteScreen(args: state.extra),
      ),

      GoRoute(
        path: app,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => DashboardTabProvider(),
          child: const DashboardScreen(),
        ),
      ),

      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final email = (state.extra as String?) ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final email = (state.extra as String?) ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),

      GoRoute(
          path: setupStep1,
          builder: (context, state) => const SetupStep1Screen()),
      GoRoute(
          path: setupStep2,
          builder: (context, state) => const SetupStep2Screen()),
      GoRoute(
          path: setupStep3,
          builder: (context, state) => const SetupStep3Screen()),
      GoRoute(
          path: setupStep4,
          builder: (context, state) => const SetupStep4Screen()),
      GoRoute(
          path: setupStep5,
          builder: (context, state) => const SetupStep5Screen()),

      GoRoute(
        path: mealDetail,
        builder: (context, state) {
          final meal = state.extra as Meal;
          return MealDetailScreen(meal: meal);
        },
      ),
      GoRoute(
        path: cookingMode,
        builder: (context, state) {
          final meal = state.extra as Meal;
          return CookingModeScreen(meal: meal);
        },
      ),
      GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfileScreen()),
      GoRoute(
          path: premium,
          builder: (context, state) => const PremiumScreen()),
      GoRoute(
          path: subscription,
          builder: (context, state) => const SubscriptionScreen()),
      GoRoute(
          path: trialActivation,
          builder: (context, state) => const TrialActivationScreen()),
      GoRoute(
          path: shoppingList,
          builder: (context, state) => const ShoppingListScreen()),
      GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen()),
      GoRoute(path: faq, builder: (context, state) => const FAQScreen()),
      GoRoute(
          path: privacyPolicy,
          builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(
          path: termsOfService,
          builder: (context, state) => const TermsOfServiceScreen()),
      GoRoute(
          path: disclaimer,
          builder: (context, state) => const DisclaimerScreen()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}