// Mock data — xóa file này ở Tuần 5 khi AI thay thế.

import 'package:cravvy_cooking_app/data/models/meal.dart';

class MealData {
  static const _base = 'https://images.unsplash.com/photo-';

  static List<DayPlan> generateWeekPlan() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: today.weekday - 1 - i));
      return DayPlan(date: date, meals: _mealsForDay(i));
    });
  }

  static List<Meal> _mealsForDay(int day) {
    const pool = [
      [
        Meal(
          id: 'b1',
          name: 'Avocado Toast Bowl',
          type: MealType.breakfast,
          calories: 420,
          protein: 18,
          carbs: 45,
          fat: 22,
          prepTime: 15,
          imageUrl: '${_base}1633862472152-e3873eb1b3ff?w=400&q=80',
          tags: ['High Protein', 'Quick'],
          isLogged: true,
        ),
        Meal(
          id: 'l1',
          name: 'Grilled Chicken Salad',
          type: MealType.lunch,
          calories: 380,
          protein: 42,
          carbs: 18,
          fat: 14,
          prepTime: 20,
          imageUrl: '${_base}1546069901-ba9599a7e63c?w=400&q=80',
          tags: ['Low Carb', 'High Protein'],
          isLogged: true,
        ),
        Meal(
          id: 'd1',
          name: 'Baked Salmon & Veggies',
          type: MealType.dinner,
          calories: 520,
          protein: 48,
          carbs: 22,
          fat: 28,
          prepTime: 35,
          imageUrl: '${_base}1467003909585-2f8a72700288?w=400&q=80',
          tags: ['Omega-3', 'Healthy'],
        ),
        Meal(
          id: 's1',
          name: 'Mixed Nuts & Fruit',
          type: MealType.snack,
          calories: 180,
          protein: 6,
          carbs: 20,
          fat: 10,
          prepTime: 2,
          imageUrl: '${_base}1495521939206-a4de60a6a1c9?w=400&q=80',
          tags: ['Quick'],
        ),
      ],
      [
        Meal(
          id: 'b2',
          name: 'Greek Yogurt Parfait',
          type: MealType.breakfast,
          calories: 350,
          protein: 22,
          carbs: 42,
          fat: 8,
          prepTime: 10,
          imageUrl: '${_base}1488477181946-6428a0291777?w=400&q=80',
          tags: ['Probiotic', 'Quick'],
          isLogged: true,
        ),
        Meal(
          id: 'l2',
          name: 'Quinoa Power Bowl',
          type: MealType.lunch,
          calories: 440,
          protein: 18,
          carbs: 58,
          fat: 16,
          prepTime: 25,
          imageUrl: '${_base}1512621776951-a57141f2eefd?w=400&q=80',
          tags: ['Vegan', 'High Fiber'],
          isLogged: true,
        ),
        Meal(
          id: 'd2',
          name: 'Stir-Fry Tofu & Broccoli',
          type: MealType.dinner,
          calories: 390,
          protein: 24,
          carbs: 34,
          fat: 18,
          prepTime: 20,
          imageUrl: '${_base}1565299624946-b28f40a0ae38?w=400&q=80',
          tags: ['Vegan', 'Quick'],
        ),
        Meal(
          id: 's2',
          name: 'Protein Smoothie',
          type: MealType.snack,
          calories: 210,
          protein: 24,
          carbs: 18,
          fat: 4,
          prepTime: 5,
          imageUrl: '${_base}1553530979-7d96cdae7b16?w=400&q=80',
          tags: ['High Protein', 'Quick'],
        ),
      ],
    ];
    return pool[day % pool.length];
  }

  static List<Meal> getAlternatives(MealType type) => [
    Meal(
      id: 'alt1',
      name: 'Oatmeal with Berries',
      type: type,
      calories: 310,
      protein: 12,
      carbs: 52,
      fat: 6,
      prepTime: 10,
      imageUrl: '${_base}1517673132405-a56a62b18caf?w=400&q=80',
      tags: ['High Fiber', 'Quick'],
    ),
    Meal(
      id: 'alt2',
      name: 'Egg White Omelette',
      type: type,
      calories: 280,
      protein: 28,
      carbs: 8,
      fat: 12,
      prepTime: 12,
      imageUrl: '${_base}1551248429-40975aa4de74?w=400&q=80',
      tags: ['High Protein', 'Low Carb'],
    ),
    Meal(
      id: 'alt3',
      name: 'Banana Pancakes',
      type: type,
      calories: 390,
      protein: 14,
      carbs: 62,
      fat: 10,
      prepTime: 20,
      imageUrl: '${_base}1567620905732-2d1ec7ab7445?w=400&q=80',
      tags: ['Gluten-Free'],
    ),
    Meal(
      id: 'alt4',
      name: 'Chia Pudding Bowl',
      type: type,
      calories: 340,
      protein: 10,
      carbs: 44,
      fat: 14,
      prepTime: 5,
      imageUrl: '${_base}1594736797933-d0501ba2fe65?w=400&q=80',
      tags: ['Vegan', 'Quick'],
    ),
  ];
}
