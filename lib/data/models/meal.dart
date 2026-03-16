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

// ─── Sample Data ─────────────────────────────────────────────────────────────
class MealData {
  static const _base = 'https://images.unsplash.com/photo-';

  static List<DayPlan> generateWeekPlan() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: today.weekday - 1 - i));
      return DayPlan(date: date, meals: _mealsForDay(i));
    });
  }

  static List<Meal> _mealsForDay(int day) {
    const pool = [
      [
        Meal(
          id: 'b1',
          name: 'Avocado Toast Bowl',
          type: MealType.breakfast,
          calories: 420,
          protein: 18,
          carbs: 45,
          fat: 22,
          prepTime: 15,
          imageUrl: '${_base}1633862472152-e3873eb1b3ff?w=400&q=80',
          tags: ['High Protein', 'Quick'],
          isLogged: true,
        ),
        Meal(
          id: 'l1',
          name: 'Grilled Chicken Salad',
          type: MealType.lunch,
          calories: 380,
          protein: 42,
          carbs: 18,
          fat: 14,
          prepTime: 20,
          imageUrl: '${_base}1546069901-ba9599a7e63c?w=400&q=80',
          tags: ['Low Carb', 'High Protein'],
          isLogged: true,
        ),
        Meal(
          id: 'd1',
          name: 'Baked Salmon & Veggies',
          type: MealType.dinner,
          calories: 520,
          protein: 48,
          carbs: 22,
          fat: 28,
          prepTime: 35,
          imageUrl: '${_base}1467003909585-2f8a72700288?w=400&q=80',
          tags: ['Omega-3', 'Healthy'],
        ),
        Meal(
          id: 's1',
          name: 'Mixed Nuts & Fruit',
          type: MealType.snack,
          calories: 180,
          protein: 6,
          carbs: 20,
          fat: 10,
          prepTime: 2,
          imageUrl: '${_base}1495521939206-a4de60a6a1c9?w=400&q=80',
          tags: ['Quick'],
        ),
      ],
      [
        Meal(
          id: 'b2',
          name: 'Greek Yogurt Parfait',
          type: MealType.breakfast,
          calories: 350,
          protein: 22,
          carbs: 42,
          fat: 8,
          prepTime: 10,
          imageUrl: '${_base}1488477181946-6428a0291777?w=400&q=80',
          tags: ['Probiotic', 'Quick'],
          isLogged: true,
        ),
        Meal(
          id: 'l2',
          name: 'Quinoa Power Bowl',
          type: MealType.lunch,
          calories: 440,
          protein: 18,
          carbs: 58,
          fat: 16,
          prepTime: 25,
          imageUrl: '${_base}1512621776951-a57141f2eefd?w=400&q=80',
          tags: ['Vegan', 'High Fiber'],
          isLogged: true,
        ),
        Meal(
          id: 'd2',
          name: 'Stir-Fry Tofu & Broccoli',
          type: MealType.dinner,
          calories: 390,
          protein: 24,
          carbs: 34,
          fat: 18,
          prepTime: 20,
          imageUrl: '${_base}1565299624946-b28f40a0ae38?w=400&q=80',
          tags: ['Vegan', 'Quick'],
        ),
        Meal(
          id: 's2',
          name: 'Protein Smoothie',
          type: MealType.snack,
          calories: 210,
          protein: 24,
          carbs: 18,
          fat: 4,
          prepTime: 5,
          imageUrl: '${_base}1553530979-7d96cdae7b16?w=400&q=80',
          tags: ['High Protein', 'Quick'],
        ),
      ],
    ];
    return pool[day % pool.length];
  }

  static List<Meal> getAlternatives(MealType type) => [
    Meal(
      id: 'alt1',
      name: 'Oatmeal with Berries',
      type: type,
      calories: 310,
      protein: 12,
      carbs: 52,
      fat: 6,
      prepTime: 10,
      imageUrl: '${_base}1517673132405-a56a62b18caf?w=400&q=80',
      tags: ['High Fiber', 'Quick'],
    ),
    Meal(
      id: 'alt2',
      name: 'Egg White Omelette',
      type: type,
      calories: 280,
      protein: 28,
      carbs: 8,
      fat: 12,
      prepTime: 12,
      imageUrl: '${_base}1551248429-40975aa4de74?w=400&q=80',
      tags: ['High Protein', 'Low Carb'],
    ),
    Meal(
      id: 'alt3',
      name: 'Banana Pancakes',
      type: type,
      calories: 390,
      protein: 14,
      carbs: 62,
      fat: 10,
      prepTime: 20,
      imageUrl: '${_base}1567620905732-2d1ec7ab7445?w=400&q=80',
      tags: ['Gluten-Free'],
    ),
    Meal(
      id: 'alt4',
      name: 'Chia Pudding Bowl',
      type: type,
      calories: 340,
      protein: 10,
      carbs: 44,
      fat: 14,
      prepTime: 5,
      imageUrl: '${_base}1594736797933-d0501ba2fe65?w=400&q=80',
      tags: ['Vegan', 'Quick'],
    ),
  ];
}
