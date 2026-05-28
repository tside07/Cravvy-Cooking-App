import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';

/// Which weekdays (0 = Mon … 6 = Sun) appear in the meal-plan week strip.
class MealPlanVisibility {
  MealPlanVisibility._();

  static int visibleDayCount(bool isPremium) => isPremium
      ? PlanLimits.premiumMealPlanVisibleDays
      : PlanLimits.freeMealPlanVisibleDays;

  static List<int> visibleDayIndices({
    required bool isPremium,
    int? todayIndex,
  }) {
    final count = visibleDayCount(isPremium);
    if (count >= 7) return List.generate(7, (i) => i);

    final today = todayIndex ?? (DateTime.now().weekday - 1);
    var start = today - (count - 1);
    if (start < 0) start = 0;
    if (start + count > 7) start = 7 - count;
    return List.generate(count, (i) => start + i);
  }

  static int clampSelectedIndex(int selected, List<int> visible) {
    if (visible.isEmpty) return 0;
    if (visible.contains(selected)) return selected;
    return visible.last;
  }

  static bool isIndexVisible(int index, List<int> visible) =>
      visible.contains(index);
}
