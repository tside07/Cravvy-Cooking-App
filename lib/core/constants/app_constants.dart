abstract final class AppConst {
  static const String appName = 'Cravvy';
  static const String appTagline = 'Your AI Meal Planner';
  static const String bundleId = 'com.tside07.cravvy';

  static const String robotoFont = 'Roboto';
  static const String nunitoFont = 'Nunito';

  // Business
  static const int otpLength = 6;
  static const int minPasswordLength = 6;

  // Nutrition defaults
  static const int defaultCalorieGoal = 2200;
  static const int defaultProteinGoal = 150;
  static const int defaultCarbsGoal = 220;
  static const int defaultFatGoal = 70;

  // UI
  static const double horizontalPadding = 24.0;
  static const double cardRadius = 20.0;
  static const double chipRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double bottomNavHeight = 72.0;

  // Animation durations
  static const Duration splashScreenDuration = Duration(milliseconds: 350);
  static const int splashDuration = 3000;
  static const int pageTransition = 300;
  static const int microAnimation = 200;

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keySelectedGoal = 'selected_goal';
  static const String keySelectedDiets = 'selected_diets';
  static const String keyCalorieGoal = 'calorie_goal';

  // ignore: library_private_types_in_public_api, non_constant_identifier_names
  static final _RegExp Pattern = _RegExp();
}

final class _RegExp {
  final RegExp nonWord = RegExp(
    r'[^\d\p{L}-]+',
    multiLine: true,
    unicode: true,
  );

  final RegExp specialCharacters = RegExp(r'[!@#$%^&.*+?{}()|[\]\\]');

  final RegExp email = RegExp(
    r'^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$',
  );

  final RegExp number = RegExp(r'\d');
}
