import 'package:cravvy_cooking_app/core/constants/app_constants.dart';
import 'package:cravvy_cooking_app/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeProvider', () {
    test('defaults to light theme', () {
      final provider = ThemeModeProvider();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, isFalse);
    });

    test('setDarkMode updates theme and persists', () async {
      final provider = ThemeModeProvider();
      await provider.setDarkMode(true);
      expect(provider.themeMode, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConst.keyDarkMode), isTrue);
    });

    test('loadSavedPreference restores dark mode', () async {
      SharedPreferences.setMockInitialValues({
        AppConst.keyDarkMode: true,
      });
      final provider = ThemeModeProvider();
      await provider.loadSavedPreference();
      expect(provider.isDarkMode, isTrue);
    });
  });
}
