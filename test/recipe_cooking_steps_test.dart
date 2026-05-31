import 'package:cravvy_cooking_app/core/utils/recipe_cooking_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecipeCookingSteps', () {
    test('parseTimerMinutes extracts Vietnamese minutes', () {
      expect(
        RecipeCookingSteps.parseTimerMinutes('Nấu thêm 20 phút cho chín đều.'),
        20,
      );
    });

    test('parseTimerMinutes extracts English minutes', () {
      expect(
        RecipeCookingSteps.parseTimerMinutes('Bake for 25 minutes until golden.'),
        25,
      );
    });

    test('parseTimerMinutes returns null when no duration', () {
      expect(
        RecipeCookingSteps.parseTimerMinutes('Chuẩn bị nguyên liệu và rửa sạch.'),
        isNull,
      );
    });

    test('fromStrings builds numbered steps with timers', () {
      final steps = RecipeCookingSteps.fromStrings([
        'Chuẩn bị nguyên liệu.',
        'Hầm 15 phút.',
      ]);
      expect(steps.length, 2);
      expect(steps[0].number, 1);
      expect(steps[0].timerMinutes, isNull);
      expect(steps[1].timerMinutes, 15);
    });
  });
}
