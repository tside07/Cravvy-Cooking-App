import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routers.dart';
import 'data/services/supabase_service.dart';
import 'data/providers/auth_provider.dart';
import 'modules/onboarding/provider/onboarding_provider.dart';
import 'modules/meal_plan/provider/meal_plan_provider.dart';
import 'modules/profile/provider/profile_provider.dart';
import 'data/providers/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // easy_localization PHẢI init trước runApp
  await EasyLocalization.ensureInitialized();

  await dotenv.load();
  await SupabaseService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MealPlanProvider()),
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          ChangeNotifierProxyProvider<MealPlanProvider, AuthProvider>(
            create: (ctx) {
              final auth = AuthProvider();
              auth.linkMealPlanProvider(ctx.read<MealPlanProvider>());
              return auth;
            },
            update: (ctx, mealPlan, auth) {
              auth!.linkMealPlanProvider(mealPlan);
              return auth;
            },
          ),
        ],
        child: const CravvyApp(),
      ),
    ),
  );
}

class CravvyApp extends StatelessWidget {
  const CravvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final el = EasyLocalization.of(context)!;

    return MaterialApp.router(
      title: 'Cravvy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      locale: el.locale,
      supportedLocales: el.supportedLocales,
      localizationsDelegates: el.delegates,
    );
  }
}
