import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premium trial is 14 days per product copy', () {
    expect(PlanLimits.premiumTrialDays, 14);
  });

  test('canStartPremiumTrial logic via UserModel', () {
    const freeUser = UserModel(
      id: 'u1',
      email: 'a@b.com',
      subscriptionTier: PlanLimits.tierFree,
    );
    expect(freeUser.isPremium, isFalse);

    final trialUser = UserModel(
      id: 'u1',
      email: 'a@b.com',
      subscriptionTier: PlanLimits.tierTrial,
      premiumUntil: DateTime.now().add(const Duration(days: 10)),
    );
    expect(trialUser.isPremium, isTrue);
  });
}
