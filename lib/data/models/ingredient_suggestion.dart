// Result of the `suggest-from-ingredients` Edge Function.
//
// Each suggestion (whether matched from the real `recipes` catalog or generated
// by Gemini) is Recipe-shaped, so [toMeal] feeds it straight into the existing
// meal detail + cooking mode flow (both routes take `state.extra as Meal`).

import 'meal.dart';

class IngredientSuggestion {
  final String name;
  final String description;
  final String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepTime;
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final List<String> steps;
  final List<String> ingredients;

  /// Extra items needed beyond what the user has (+ basic seasonings).
  /// Empty when the dish is fully covered by the provided ingredients.
  final List<String> missingIngredients;
  final String? imageUrl;

  /// 'db' (matched real recipe) or 'ai' (Gemini-generated).
  final String source;

  const IngredientSuggestion({
    required this.name,
    required this.description,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.difficulty,
    required this.steps,
    required this.ingredients,
    required this.missingIngredients,
    required this.imageUrl,
    required this.source,
  });

  factory IngredientSuggestion.fromJson(Map<String, dynamic> json) {
    return IngredientSuggestion(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'lunch',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      prepTime: (json['prep_time'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'easy',
      steps: (json['steps'] as List<dynamic>?)?.cast<String>() ?? const [],
      ingredients:
          (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? const [],
      missingIngredients:
          (json['missing_ingredients'] as List<dynamic>?)?.cast<String>() ??
              const [],
      imageUrl: json['image_url'] as String?,
      source: json['source'] as String? ?? 'ai',
    );
  }

  bool get isAiGenerated => source == 'ai';

  /// Build a [Meal] so the suggestion opens in the shared detail/cooking flow.
  /// AI dishes have no DB row, so [id]/[recipeId] use a synthetic local key.
  Meal toMeal() {
    return Meal(
      id: 'ai:${name.hashCode}',
      recipeId: 'ai:${name.hashCode}',
      name: name,
      type: _parseMealType(mealType),
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      prepTime: prepTime,
      imageUrl: imageUrl ?? '',
      steps: steps,
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
}
