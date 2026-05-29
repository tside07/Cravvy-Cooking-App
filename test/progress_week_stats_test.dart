import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/modules/progress/screens/progress_screen.dart';
import 'package:flutter_test/flutter_test.dart';

DayPlan _dayWithLoggedMeals({
  required DateTime date,
  required int loggedMealCount,
  int caloriesPerMeal = 500,
}) {
  final meals = List.generate(
    loggedMealCount,
    (i) => Meal(
      id: 'meal-$i',
      recipeId: 'recipe-$i',
      name: 'Meal $i',
      type: MealType.breakfast,
      calories: caloriesPerMeal,
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
  group('ProgressScreen.buildWeekStats', () {
    const targetCalories = 2000;
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

    test('empty weekPlan returns zeros', () {
      final stats = ProgressScreen.buildWeekStats(
        [],
        targetCalories,
        todayIndex: 3,
      );

      expect(stats.streak, 0);
      expect(stats.mealsLogged, 0);
      expect(stats.goalHitPercent, 0);
    });

    test('3 days with logged meals sums meals and streak from today', () {
      // Mon–Sun: logged on Thu(3), Fri(4), Sat(5) — 2 meals each
      final weekPlan = weekOf([0, 0, 0, 2, 2, 2, 0]);

      final stats = ProgressScreen.buildWeekStats(
        weekPlan,
        targetCalories,
        todayIndex: 5, // Saturday — streak Sat, Fri, Thu = 3
      );

      expect(stats.streak, 3);
      expect(stats.mealsLogged, 6);
      expect(stats.goalHitPercent, 0); // 500*2=1000 < 1800 threshold
    });

    test('all 7 days with logged meals', () {
      final weekPlan = weekOf(List.filled(7, 1));

      final stats = ProgressScreen.buildWeekStats(
        weekPlan,
        targetCalories,
        todayIndex: 6, // Sunday — full week streak
      );

      expect(stats.streak, 7);
      expect(stats.mealsLogged, 7);
      expect(stats.goalHitPercent, 0);
    });
  });
}
