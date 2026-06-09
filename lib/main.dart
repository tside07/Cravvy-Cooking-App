import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/routes/app_routers.dart';
import 'data/services/supabase_service.dart';
import 'data/providers/auth_provider.dart';
import 'modules/meal_plan/provider/meal_plan_provider.dart';
import 'modules/profile/provider/profile_provider.dart';
import 'data/providers/recipe_provider.dart';
import 'modules/shopping_list/provider/shopping_list_provider.dart';

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
      fallbackLocale: const Locale('vi', 'VN'),
      startLocale: const Locale('vi', 'VN'),
      saveLocale: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              final theme = ThemeModeProvider();
              theme.loadSavedPreference();
              return theme;
            },
          ),
          ChangeNotifierProvider(create: (_) => MealPlanProvider()),
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
          ChangeNotifierProxyProvider<MealPlanProvider, AuthProvider>(
            create: (ctx) {
              final auth = AuthProvider();
              auth.linkMealPlanProvider(ctx.read<MealPlanProvider>());
              auth.linkRecipeProvider(ctx.read<RecipeProvider>());
              auth.linkShoppingListProvider(ctx.read<ShoppingListProvider>());
              return auth;
            },
            update: (ctx, mealPlan, auth) {
              auth!.linkMealPlanProvider(mealPlan);
              auth.linkRecipeProvider(ctx.read<RecipeProvider>());
              auth.linkShoppingListProvider(ctx.read<ShoppingListProvider>());
              return auth;
            },
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
            create: (_) => ProfileProvider(),
            update: (_, auth, profile) {
              profile!.syncFromUser(auth.user);
              return profile;
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

    return Consumer<ThemeModeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp.router(
          title: 'Cravvy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
          locale: el.locale,
          supportedLocales: el.supportedLocales,
          localizationsDelegates: el.delegates,
        );
      },
    );
  }
}
