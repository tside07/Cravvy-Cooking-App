import 'package:cravvy_cooking_app/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists dark-mode preference locally between app sessions.
abstract final class ThemePreferenceStorage {
  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConst.keyDarkMode) ?? false;
  }

  static Future<void> save(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConst.keyDarkMode, isDark);
  }
}
