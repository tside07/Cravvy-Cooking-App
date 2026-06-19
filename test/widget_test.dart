import 'package:cravvy_cooking_app/core/utils/meal_plan_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test placeholder — full app widget test needs Supabase/EasyLocalization.
void main() {
  test('meal plan visibility smoke', () {
    expect(
      MealPlanVisibility.visibleDayCount(false),
      3,
    );
  });
}
