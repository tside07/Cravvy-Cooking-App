import 'package:flutter/foundation.dart';
import '../../../data/models/meal.dart';

class MealPlanProvider extends ChangeNotifier {
  late List<DayPlan> _weekPlan;
  int _selectedDayIndex;
  static const int _targetCalories = 2200;
  static const int _targetProtein = 150;
  static const int _targetCarbs = 220;
  static const int _targetFat = 70;

  MealPlanProvider() : _selectedDayIndex = _todayIndex() {
    _weekPlan = MealData.generateWeekPlan();
  }

  static int _todayIndex() {
    final today = DateTime.now();
    return today.weekday - 1;
  }

  List<DayPlan> get weekPlan => _weekPlan;
  int get selectedDayIndex => _selectedDayIndex;
  DayPlan get selectedDay => _weekPlan[_selectedDayIndex];

  int get targetCalories => _targetCalories;
  int get targetProtein => _targetProtein;
  int get targetCarbs => _targetCarbs;
  int get targetFat => _targetFat;

  double get calorieProgress =>
      (selectedDay.totalCalories / _targetCalories).clamp(0.0, 1.0);
  double get proteinProgress =>
      (selectedDay.totalProtein / _targetProtein).clamp(0.0, 1.0);
  double get carbsProgress =>
      (selectedDay.totalCarbs / _targetCarbs).clamp(0.0, 1.0);
  double get fatProgress => (selectedDay.totalFat / _targetFat).clamp(0.0, 1.0);

  int get remainingCalories => _targetCalories - selectedDay.totalCalories;

  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }

  void toggleMealLogged(String mealId) {
    final dayPlan = _weekPlan[_selectedDayIndex];
    final meals = dayPlan.meals.map((m) {
      if (m.id == mealId) return m.copyWith(isLogged: !m.isLogged);
      return m;
    }).toList();
    _weekPlan[_selectedDayIndex] = dayPlan.copyWith(meals: meals);
    notifyListeners();
  }

  void swapMeal(String oldMealId, Meal newMeal) {
    final dayPlan = _weekPlan[_selectedDayIndex];
    final meals = dayPlan.meals.map((m) {
      if (m.id == oldMealId) return newMeal;
      return m;
    }).toList();
    _weekPlan[_selectedDayIndex] = dayPlan.copyWith(meals: meals);
    notifyListeners();
  }
}
