import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast:
        return AppColors.breakfast;
      case MealType.lunch:
        return AppColors.lunch;
      case MealType.dinner:
        return AppColors.dinner;
      case MealType.snack:
        return AppColors.snack;
    }
  }

  Color get lightColor {
    switch (this) {
      case MealType.breakfast:
        return AppColors.primaryLight;
      case MealType.lunch:
        return AppColors.secondaryLight;
      case MealType.dinner:
        return const Color(0xFFEDE9FE);
      case MealType.snack:
        return AppColors.warningLight;
    }
  }
}

class Meal {
  final String id;
  final String name;
  final MealType type;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepTime;
  final String imageUrl;
  final bool isLogged;
  final List<String> tags;
  final List<String> steps; // từ Recipe.steps — TEXT[]

  const Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.imageUrl,
    this.isLogged = false,
    this.tags = const [],
    this.steps = const [],
  });

  Meal copyWith({bool? isLogged}) => Meal(
    id: id,
    name: name,
    type: type,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    prepTime: prepTime,
    imageUrl: imageUrl,
    isLogged: isLogged ?? this.isLogged,
    tags: tags,
    steps: steps,
  );
}

class DayPlan {
  final DateTime date;
  final List<Meal> meals;

  const DayPlan({required this.date, required this.meals});

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  int get totalProtein => meals.fold(0, (sum, m) => sum + m.protein);
  int get totalCarbs => meals.fold(0, (sum, m) => sum + m.carbs);
  int get totalFat => meals.fold(0, (sum, m) => sum + m.fat);
  int get loggedCount => meals.where((m) => m.isLogged).length;
  bool get isComplete => loggedCount == meals.length;

  DayPlan copyWith({List<Meal>? meals}) =>
      DayPlan(date: date, meals: meals ?? this.meals);
}
