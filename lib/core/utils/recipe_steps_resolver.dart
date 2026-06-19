import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/data/services/recipe_service.dart';

/// Resolves instruction lines for a [Meal] from embedded data or Supabase.
abstract final class RecipeStepsResolver {
  static Future<List<String>> resolveLines(
    Meal meal, {
    RecipeProvider? recipeLookup,
  }) async {
    if (meal.steps.isNotEmpty) {
      return meal.steps;
    }

    if (recipeLookup != null) {
      for (final recipe in recipeLookup.allRecipes) {
        if (recipe.id == meal.recipeId && recipe.steps.isNotEmpty) {
          return recipe.steps;
        }
      }
    }

    final remote = await RecipeService.fetchById(meal.recipeId);
    if (remote != null && remote.steps.isNotEmpty) {
      return remote.steps;
    }

    return const [];
  }
}
