import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/core/utils/meal_plan_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealPlanVisibility', () {
    test('premium shows all 7 days', () {
      expect(
        MealPlanVisibility.visibleDayIndices(isPremium: true),
        [0, 1, 2, 3, 4, 5, 6],
      );
      expect(MealPlanVisibility.visibleDayCount(true), 7);
    });

    test('free shows 3 days ending on today when possible', () {
      expect(
        MealPlanVisibility.visibleDayIndices(isPremium: false, todayIndex: 6),
        [4, 5, 6],
      );
      expect(
        MealPlanVisibility.visibleDayIndices(isPremium: false, todayIndex: 0),
        [0, 1, 2],
      );
      expect(
        MealPlanVisibility.visibleDayIndices(isPremium: false, todayIndex: 3),
        [1, 2, 3],
      );
    });

    test('clampSelectedIndex keeps visible or last visible', () {
      const visible = [1, 2, 3];
      expect(MealPlanVisibility.clampSelectedIndex(2, visible), 2);
      expect(MealPlanVisibility.clampSelectedIndex(6, visible), 3);
      expect(MealPlanVisibility.isIndexVisible(2, visible), isTrue);
      expect(MealPlanVisibility.isIndexVisible(0, visible), isFalse);
    });
  });

  group('PlanLimits', () {
    test('swap quotas by tier', () {
      expect(PlanLimits.swapsPerWeek(PlanLimits.tierFree), 2);
      expect(PlanLimits.swapsPerWeek(PlanLimits.tierPremium), 5);
      expect(PlanLimits.swapsPerWeek(PlanLimits.tierTrial), 5);
    });

    test('visible day counts', () {
      expect(PlanLimits.freeMealPlanVisibleDays, 3);
      expect(PlanLimits.premiumMealPlanVisibleDays, 7);
    });
  });
}
