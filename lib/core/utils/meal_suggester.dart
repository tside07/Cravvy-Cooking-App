// lib/core/utils/meal_suggester.dart
//
// Logic gợi ý món ăn cho từng slot.
// Dùng hash(userId + weekNumber + dayOffset) làm seed → mỗi ngày/tuần khác nhau,
// nhưng deterministic trong cùng tuần (reload không đổi thứ tự).

import 'package:cravvy_cooking_app/core/utils/profile_recipe_filter.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';

extension WeekOfYear on DateTime {
  int get weekOfYear {
    final startOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(startOfYear).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}

class MealSuggester {
  // Gợi ý cả 4 slots cho 1 ngày — trả Map<mealType, Recipe>
  static Map<String, Recipe> suggestDay({
    required Map<String, List<Recipe>> byType,
    required UserModel user,
    required int weekNumber,
    int dayOffset = 0,
  }) {
    final result = <String, Recipe>{};
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final candidates = byType[mealType] ?? [];
      if (candidates.isEmpty) continue;

      var pool = ProfileRecipeFilter.filterRecipes(candidates, user);
      if (pool.isEmpty) continue;

      if (user.cookingTime == 'quick' || user.cookingTime == '15') {
        final quick = pool.where((r) => r.prepTime <= 20).toList();
        if (quick.isNotEmpty) pool = quick;
      }

      final scored = [...pool]
        ..sort(
          (a, b) => ProfileRecipeFilter.scoreRecipe(b, user)
              .compareTo(ProfileRecipeFilter.scoreRecipe(a, user)),
        );

      final topN = scored.take(5).toList();
      if (topN.isEmpty) continue;

      final seed =
          (user.id.hashCode.abs()) +
          (weekNumber * 31) +
          (mealType.hashCode.abs() % 100) +
          (dayOffset * 7);
      result[mealType] = topN[seed % topN.length];
    }
    return result;
  }
}
