import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExt on MealType {
  /// English fallback for debug / non-UI use.
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

  /// Localized label via `assets/translations`.
  String get localizedLabel {
    switch (this) {
      case MealType.breakfast:
        return 'meal_plan.meal_breakfast'.tr();
      case MealType.lunch:
        return 'meal_plan.meal_lunch'.tr();
      case MealType.dinner:
        return 'meal_plan.meal_dinner'.tr();
      case MealType.snack:
        return 'meal_plan.meal_snack'.tr();
    }
  }

  /// Material rounded icon theo bữa — thay cho emoji, dùng kèm [color].
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.wb_twilight_rounded;
      case MealType.lunch:
        return Icons.wb_sunny_rounded;
      case MealType.dinner:
        return Icons.nightlight_round;
      case MealType.snack:
        return Icons.cookie_rounded;
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
  /// `meal_plans` row id when loaded from Supabase; recipe uuid when optimistic/local.
  final String id;
  /// Always the `recipes.id` for this slot.
  final String recipeId;
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
  final List<String> ingredients;

  const Meal({
    required this.id,
    required this.recipeId,
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
    this.ingredients = const [],
  });

  Meal copyWith({
    String? id,
    String? recipeId,
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
    List<String>? ingredients,
  }) => Meal(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
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
    ingredients: ingredients ?? this.ingredients,
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
