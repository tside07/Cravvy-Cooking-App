import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps Flutter Free-catalog filter aligned with Edge Function + seed source.
void main() {
  test('free recipe sources include curated VN catalog', () {
    expect(PlanLimits.freeRecipeSources, contains('cravvy_curated_vn'));
  });

  test('free catalog fetch limit supports ~100 recipes', () {
    expect(PlanLimits.freeRecipeFetchLimit, greaterThanOrEqualTo(100));
  });
}
