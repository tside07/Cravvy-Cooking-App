import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/models/meal_data.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/core/utils/nutrition_calculator.dart';

class MealPlanProvider extends ChangeNotifier {
  late List<DayPlan> _weekPlan;
  int _selectedDayIndex;
  NutritionTarget _target;

  MealPlanProvider()
    : _selectedDayIndex = _todayIndex(),
      _target = NutritionTarget.defaultTarget {
    _weekPlan = MealData.generateWeekPlan();
  }

  static int _todayIndex() {
    final today = DateTime.now();
    return today.weekday - 1; // Mon=0, Sun=6
  }

  void updateFromUser(UserModel? user) {
    if (user == null) {
      _target = NutritionTarget.defaultTarget;
    } else {
      _target = NutritionCalculator.calculate(
        age: user.age,
        gender: user.gender,
        weightKg: user.weightKg,
        heightCm: user.heightCm,
        goal: user.goal,
      );
    }
    notifyListeners();
  }

  List<DayPlan> get weekPlan => _weekPlan;
  int get selectedDayIndex => _selectedDayIndex;
  DayPlan get selectedDay => _weekPlan[_selectedDayIndex];

  int get targetCalories => _target.calories;
  int get targetProtein => _target.protein;
  int get targetCarbs => _target.carbs;
  int get targetFat => _target.fat;

  double get calorieProgress =>
      (selectedDay.totalCalories / _target.calories).clamp(0.0, 1.0);
  double get proteinProgress =>
      (selectedDay.totalProtein / _target.protein).clamp(0.0, 1.0);
  double get carbsProgress =>
      (selectedDay.totalCarbs / _target.carbs).clamp(0.0, 1.0);
  double get fatProgress =>
      (selectedDay.totalFat / _target.fat).clamp(0.0, 1.0);

  int get remainingCalories => _target.calories - selectedDay.totalCalories;

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
