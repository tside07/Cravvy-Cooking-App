// lib/core/utils/meal_suggester.dart
//
// Logic gợi ý món ăn cho từng slot.
// Dùng hash(userId + weekNumber + dayOffset) làm seed → mỗi ngày/tuần khác nhau,
// nhưng deterministic trong cùng tuần (reload không đổi thứ tự).
//
// Tuần 5: thay suggestDay() bằng Gemini output. Class này thành fallback.

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

      // 1. Filter avoidFoods
      var pool = _applyAvoidFoods(candidates, user.avoidFoods);
      if (pool.isEmpty) pool = candidates; // fallback nếu filter quá chặt

      // 2. Filter cooking time
      if (user.cookingTime == 'quick' || user.cookingTime == '15') {
        final quick = pool.where((r) => r.prepTime <= 20).toList();
        if (quick.isNotEmpty) pool = quick;
      }

      // 3. Score theo goal + diet
      final scored = [...pool]
        ..sort((a, b) => _score(b, user).compareTo(_score(a, user)));

      // 4. Top 5 để có rotation
      final topN = scored.take(5).toList();

      // 5. Deterministic pick theo seed
      final seed =
          (user.id.hashCode.abs()) +
          (weekNumber * 31) +
          (mealType.hashCode.abs() % 100) +
          (dayOffset * 7);
      result[mealType] = topN[seed % topN.length];
    }
    return result;
  }

  static List<Recipe> _applyAvoidFoods(
    List<Recipe> recipes,
    List<String> avoid,
  ) {
    if (avoid.isEmpty) return recipes;
    return recipes.where((r) {
      final nameLower = r.name.toLowerCase();
      final tagsLower = r.tags.map((t) => t.toLowerCase()).toList();
      return !avoid.any(
        (a) =>
            nameLower.contains(a.toLowerCase()) ||
            tagsLower.any((t) => t.contains(a.toLowerCase())),
      );
    }).toList();
  }

  static int _score(Recipe r, UserModel user) {
    int score = 0;
    switch (user.goal) {
      case 'lose-weight':
        if (r.calories < 350) score += 3;
        if (r.calories < 450) score += 1;
        if (r.tags.any((t) => t.toLowerCase().contains('low carb'))) score += 2;
        break;
      case 'build-muscle':
        if (r.protein >= 30) score += 4;
        if (r.protein >= 20) score += 2;
        if (r.tags.any((t) => t.toLowerCase().contains('high protein')))
          score += 2;
        break;
      default:
        if (r.calories < 600) score += 1;
    }
    for (final diet in user.diets) {
      if (r.tags.any((t) => t.toLowerCase().contains(diet.toLowerCase()))) {
        score += 3;
      }
    }
    return score;
  }
}
