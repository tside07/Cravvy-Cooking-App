// lib/data/models/recipe.dart
//
// Model cho bảng `recipes` trên Supabase.
// Tách riêng với `Meal` (dùng cho mock/meal_plan) để không phá
// các screen đang chạy. Khi Tuần 5 implement AI meal plan thật,
// sẽ convert Recipe → Meal bằng toMeal().

import 'meal.dart';

class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepTime;
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  final List<String> tags;
  final List<String> steps;
  final List<String> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.difficulty,
    required this.mealType,
    this.tags = const [],
    this.steps = const [],
    this.ingredients = const [],
  });

  // ─── Supabase → Recipe ───────────────────────────────────────────────────
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      prepTime: (json['prep_time'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'easy',
      mealType: json['meal_type'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      steps: (json['steps'] as List<dynamic>?)?.cast<String>() ?? [],
      ingredients:
          (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // ─── Recipe → Meal (để tương thích với UI hiện tại) ──────────────────────
  Meal toMeal() {
    return Meal(
      id: id,
      recipeId: id,
      name: name,
      type: _parseMealType(mealType),
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      prepTime: prepTime,
      imageUrl: imageUrl ?? '',
      tags: tags,
      steps: steps, // ← pass steps thật
      ingredients: ingredients,
    );
  }

  static MealType _parseMealType(String raw) {
    switch (raw) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.lunch;
    }
  }

  Recipe copyWith({
    String? name,
    String? description,
    String? imageUrl,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? prepTime,
    String? difficulty,
    String? mealType,
    List<String>? tags,
    List<String>? steps,
    List<String>? ingredients,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      prepTime: prepTime ?? this.prepTime,
      difficulty: difficulty ?? this.difficulty,
      mealType: mealType ?? this.mealType,
      tags: tags ?? this.tags,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
