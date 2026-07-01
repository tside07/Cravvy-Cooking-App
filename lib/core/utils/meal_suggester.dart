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
  /// Hash ổn định (FNV-1a) — KHÔNG phụ thuộc String.hashCode (có thể đổi giữa các
  /// lần chạy), để gợi ý nhất quán trong cùng tuần.
  static int _stableHash(String s) {
    var h = 2166136261;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 16777619) & 0x7fffffff;
    }
    return h;
  }

  /// Số ngày trong cửa sổ cần khác nhau (1 tuần).
  static const _weekSpan = 7;

  /// Cửa sổ ranking tối đa để xoay vòng — đủ rộng cho cả tuần khác nhau nhưng
  /// vẫn thiên về món điểm cao.
  static const _maxWindow = 21;

  // Gợi ý cả 4 slots cho 1 ngày — trả Map<mealType, Recipe>.
  //
  // Đa dạng theo tuần: mỗi slot xoay qua cửa sổ món-điểm-cao theo dayOffset
  // (bước 1) nên 7 ngày liên tiếp KHÁC nhau (khi đủ ≥7 món hợp lệ); base theo
  // (user, tuần, slot) nên mỗi tuần lại đổi bộ món.
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

      // Cửa sổ ≥ 7 (để cả tuần khác nhau) và ≤ _maxWindow (giữ chất lượng).
      final windowLen = scored.length <= _weekSpan
          ? scored.length
          : (scored.length < _maxWindow ? scored.length : _maxWindow);
      final window = scored.take(windowLen).toList();
      if (window.isEmpty) continue;

      final base = _stableHash('${user.id}|$weekNumber|$mealType');
      final idx = (base + dayOffset) % window.length;
      result[mealType] = window[idx];
    }
    return result;
  }
}
