import 'package:cravvy_cooking_app/data/services/theme_preference_storage.dart';
import 'package:flutter/material.dart';

/// App-wide theme mode (light/dark) with SharedPreferences persistence.
class ThemeModeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSavedPreference() async {
    final dark = await ThemePreferenceStorage.load();
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final next = value ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
    await ThemePreferenceStorage.save(value);
  }
}
