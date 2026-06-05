import 'package:cravvy_cooking_app/core/utils/meal_plan_streak.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:flutter_test/flutter_test.dart';

DayPlan _dayWithLoggedMeals({
  required DateTime date,
  required int loggedMealCount,
}) {
  final meals = List.generate(
    loggedMealCount,
    (i) => Meal(
      id: 'meal-$i',
      recipeId: 'recipe-$i',
      name: 'Meal $i',
      type: MealType.breakfast,
      calories: 500,
      protein: 10,
      carbs: 10,
      fat: 5,
      prepTime: 15,
      imageUrl: '',
      isLogged: true,
    ),
  );
  return DayPlan(date: date, meals: meals);
}

DayPlan _emptyDay(DateTime date) => DayPlan(date: date, meals: const []);

void main() {
  group('MealPlanStreak.days', () {
    final weekStart = DateTime(2026, 5, 25); // Monday

    List<DayPlan> weekOf(List<int> loggedMealsPerDay) {
      return List.generate(
        7,
        (i) => loggedMealsPerDay[i] > 0
            ? _dayWithLoggedMeals(
                date: weekStart.add(Duration(days: i)),
                loggedMealCount: loggedMealsPerDay[i],
              )
            : _emptyDay(weekStart.add(Duration(days: i))),
      );
    }

    test('empty weekPlan returns 0', () {
      expect(MealPlanStreak.days([]), 0);
    });

    test('counts consecutive logged days backward from today', () {
      final weekPlan = weekOf([0, 0, 0, 2, 2, 2, 0]);

      expect(MealPlanStreak.days(weekPlan, todayIndex: 5), 3);
    });

    test('streak stops at first day without logged meals', () {
      final weekPlan = weekOf([0, 0, 0, 1, 1, 0, 1]);

      expect(MealPlanStreak.days(weekPlan, todayIndex: 6), 1);
    });

    test('full week streak when every day has logged meals', () {
      final weekPlan = weekOf(List.filled(7, 1));

      expect(MealPlanStreak.days(weekPlan, todayIndex: 6), 7);
    });

    test('today with no logged meals returns 0', () {
      final weekPlan = weekOf([1, 1, 1, 0, 0, 0, 0]);

      expect(MealPlanStreak.days(weekPlan, todayIndex: 6), 0);
    });
  });
}
