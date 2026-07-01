import 'package:flutter_test/flutter_test.dart';
import 'package:cravvy_cooking_app/core/utils/meal_suggester.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';

Recipe _r(String id, String meal, int i) => Recipe(
      id: id,
      name: 'Món $meal $i',
      calories: 300 + i * 10,
      protein: 20 + i,
      carbs: 30 + i,
      fat: 10 + i,
      prepTime: 25,
      difficulty: 'easy',
      mealType: meal,
    );

void main() {
  const user = UserModel(id: 'u1', email: 'a@b.com', fullName: 'A B');
  const slots = ['breakfast', 'lunch', 'dinner', 'snack'];

  Map<String, List<Recipe>> byTypeWith(int n) => {
        for (final s in slots) s: [for (var i = 0; i < n; i++) _r('${s}_$i', s, i)],
      };

  test('7 ngày liên tiếp KHÁC nhau từng slot khi pool >= 7', () {
    final byType = byTypeWith(12);
    for (final slot in slots) {
      final picks = <String>{};
      for (var day = 0; day < 7; day++) {
        final r = MealSuggester.suggestDay(
          byType: byType,
          user: user,
          weekNumber: 5,
          dayOffset: day,
        )[slot];
        picks.add(r!.id);
      }
      expect(picks.length, 7, reason: 'slot $slot phải có 7 món khác nhau');
    }
  });

  test('reload cùng (tuần, ngày) cho kết quả nhất quán', () {
    final byType = byTypeWith(12);
    final a = MealSuggester.suggestDay(byType: byType, user: user, weekNumber: 5, dayOffset: 3);
    final b = MealSuggester.suggestDay(byType: byType, user: user, weekNumber: 5, dayOffset: 3);
    for (final s in slots) {
      expect(a[s]!.id, b[s]!.id, reason: 'slot $s phải ổn định');
    }
  });

  test('tuần khác -> bộ món đổi (ít nhất 1 slot khác)', () {
    final byType = byTypeWith(12);
    final w5 = MealSuggester.suggestDay(byType: byType, user: user, weekNumber: 5, dayOffset: 0);
    final w6 = MealSuggester.suggestDay(byType: byType, user: user, weekNumber: 6, dayOffset: 0);
    final changed = slots.any((s) => w5[s]!.id != w6[s]!.id);
    expect(changed, isTrue);
  });

  test('pool nhỏ (<7) không crash, vẫn trả món', () {
    final byType = byTypeWith(3);
    for (var day = 0; day < 7; day++) {
      final res = MealSuggester.suggestDay(byType: byType, user: user, weekNumber: 5, dayOffset: day);
      expect(res['lunch'], isNotNull);
    }
  });
}
