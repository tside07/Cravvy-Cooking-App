import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/usage_limit_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsageLimitService.weekStartMonday', () {
    test('returns Monday 00:00 UTC for mid-week date', () {
      // Wednesday 2026-05-20
      final ref = DateTime(2026, 5, 20, 15, 30);
      final mon = UsageLimitService.weekStartMonday(ref);
      expect(mon.weekday, DateTime.monday);
      expect(mon.year, 2026);
      expect(mon.month, 5);
      expect(mon.day, 18);
      expect(mon.hour, 0);
      expect(mon.minute, 0);
    });
  });

  group('UsageLimitService.userHasPremium', () {
    test('trial without expiry is premium', () {
      const user = UserModel(
        id: 'u1',
        email: 'a@b.com',
        subscriptionTier: 'trial',
      );
      expect(UsageLimitService.userHasPremium(user), isTrue);
    });

    test('premium with past expiry is not premium', () {
      final user = UserModel(
        id: 'u1',
        email: 'a@b.com',
        subscriptionTier: 'premium',
        premiumUntil: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(UsageLimitService.userHasPremium(user), isFalse);
    });

    test('free tier is not premium', () {
      const user = UserModel(
        id: 'u1',
        email: 'a@b.com',
        subscriptionTier: 'free',
      );
      expect(UsageLimitService.userHasPremium(user), isFalse);
    });
  });
}
