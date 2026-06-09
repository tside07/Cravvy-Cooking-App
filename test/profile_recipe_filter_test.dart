import 'package:cravvy_cooking_app/core/utils/profile_recipe_filter.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _recipe({
  required String id,
  String name = 'Test dish',
  List<String> tags = const [],
  List<String> ingredients = const [],
  int carbs = 10,
  int protein = 20,
  int calories = 300,
}) {
  return Recipe(
    id: id,
    name: name,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: 10,
    prepTime: 15,
    difficulty: 'easy',
    mealType: 'lunch',
    tags: tags,
    ingredients: ingredients,
  );
}

UserModel _user({
  List<String> diets = const [],
  List<String> avoidFoods = const [],
  String goal = 'maintain',
}) {
  return UserModel(
    id: 'user-1',
    email: 'test@example.com',
    diets: diets,
    avoidFoods: avoidFoods,
    goal: goal,
  );
}

void main() {
  group('ProfileRecipeFilter', () {
    test('No Pork maps to pork tag', () {
      final recipe = _recipe(id: '1', tags: ['vietnamese', 'pork']);
      final user = _user(avoidFoods: ['No Pork']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isFalse);
    });

    test('Dairy detected in ingredients', () {
      final recipe = _recipe(
        id: '2',
        ingredients: ['200ml fresh milk', 'oats'],
      );
      final user = _user(avoidFoods: ['Dairy']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isFalse);
    });

    test('Vegan excludes chicken tag', () {
      final recipe = _recipe(id: '3', tags: ['chicken', 'high protein']);
      final user = _user(diets: ['Vegan']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isFalse);
    });

    test('Vegetarian allows dairy', () {
      final recipe = _recipe(id: '4', tags: ['dairy', 'vegetarian']);
      final user = _user(diets: ['Vegetarian']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isTrue);
    });

    test('Low-Carb diet tag matches Low-Carb selection in scoring', () {
      final lowCarb = _recipe(id: '5', tags: ['low carb'], carbs: 20);
      final highCarb = _recipe(id: '6', tags: ['rice'], carbs: 60);
      final user = _user(diets: ['Low-Carb'], goal: 'lose-weight');

      expect(
        ProfileRecipeFilter.scoreRecipe(lowCarb, user),
        greaterThan(ProfileRecipeFilter.scoreRecipe(highCarb, user)),
      );
    });

    test('Keto rejects high carb without keto tag', () {
      final recipe = _recipe(id: '7', tags: ['rice'], carbs: 55);
      final user = _user(diets: ['Keto']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isFalse);
    });

    test('filterRecipes returns empty when nothing matches', () {
      final recipes = [
        _recipe(id: '8', tags: ['pork']),
        _recipe(id: '9', tags: ['beef']),
      ];
      final user = _user(avoidFoods: ['No Pork', 'No Beef']);

      expect(ProfileRecipeFilter.filterRecipes(recipes, user), isEmpty);
    });

    test('No Specific Diet skips hard diet filters', () {
      final recipe = _recipe(id: '10', tags: ['pork']);
      final user = _user(diets: ['No Specific Diet']);

      expect(ProfileRecipeFilter.matchesProfile(recipe, user), isTrue);
    });
  });
}
