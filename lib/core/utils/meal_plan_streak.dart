import 'package:cravvy_cooking_app/data/models/meal.dart';

/// Consecutive days with at least one logged meal, counting backward from today.
class MealPlanStreak {
  MealPlanStreak._();

  /// [todayIndex] Mon=0 … Sun=6; defaults to calendar today.
  static int days(
    List<DayPlan> weekPlan, {
    int? todayIndex,
  }) {
    if (weekPlan.isEmpty) return 0;

    final today = todayIndex ?? DateTime.now().weekday - 1;
    final clampedToday = today.clamp(0, weekPlan.length - 1);

    var streak = 0;
    for (var i = clampedToday; i >= 0; i--) {
      if (weekPlan[i].loggedCount <= 0) break;
      streak++;
    }
    return streak;
  }
}
