import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _mealReminder = true;
  bool _dailySuggestion = true;
  bool _waterReminder = false;
  bool _newsUpdates = true;

  bool get mealReminder => _mealReminder;
  bool get dailySuggestion => _dailySuggestion;
  bool get waterReminder => _waterReminder;
  bool get newsUpdates => _newsUpdates;

  void setMealReminder(bool value) {
    _mealReminder = value;
    notifyListeners();
  }

  void setDailySuggestion(bool value) {
    _dailySuggestion = value;
    notifyListeners();
  }

  void setWaterReminder(bool value) {
    _waterReminder = value;
    notifyListeners();
  }

  void setNewsUpdates(bool value) {
    _newsUpdates = value;
    notifyListeners();
  }

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  bool _showDeleteConfirm = false;

  bool get showDeleteConfirm => _showDeleteConfirm;

  void showDeleteConfirmCard() {
    _showDeleteConfirm = true;
    notifyListeners();
  }

  void hideDeleteConfirmCard() {
    _showDeleteConfirm = false;
    notifyListeners();
  }
}
