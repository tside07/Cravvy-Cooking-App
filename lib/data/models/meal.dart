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

// ─── Meal model ───────────────────────────────────────────────────────────────

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
  final List<String> steps;

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

  Meal copyWith({
    String? id,
    String? name,
    MealType? type,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? prepTime,
    String? imageUrl,
    bool? isLogged,
    List<String>? tags,
    List<String>? steps,
  }) => Meal(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    prepTime: prepTime ?? this.prepTime,
    imageUrl: imageUrl ?? this.imageUrl,
    isLogged: isLogged ?? this.isLogged,
    tags: tags ?? this.tags,
    steps: steps ?? this.steps,
  );
}

// ─── DayPlan ──────────────────────────────────────────────────────────────────

class DayPlan {
  final DateTime date;
  final List<Meal> meals;

  const DayPlan({required this.date, required this.meals});

  int get totalCalories => meals.fold(0, (s, m) => s + m.calories);
  int get totalProtein => meals.fold(0, (s, m) => s + m.protein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.carbs);
  int get totalFat => meals.fold(0, (s, m) => s + m.fat);
  int get loggedCount => meals.where((m) => m.isLogged).length;
  bool get isComplete => meals.isNotEmpty && loggedCount == meals.length;

  DayPlan copyWith({List<Meal>? meals}) =>
      DayPlan(date: date, meals: meals ?? this.meals);
}
