import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Map<String, dynamic>> loadLocale(String file) async {
    final raw = await rootBundle.loadString('assets/translations/$file');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  test('vi-VN meal_plan and meal_detail keys exist', () async {
    final vi = await loadLocale('vi-VN.json');
    final mealPlan = vi['meal_plan'] as Map<String, dynamic>;
    final mealDetail = vi['meal_detail'] as Map<String, dynamic>;

    expect(mealPlan['title'], 'Kế hoạch ăn');
    expect(mealPlan['meal_breakfast'], 'Bữa sáng');
    expect(mealDetail['tab_ingredients'], 'Nguyên liệu');
    expect(mealDetail['add_missing'], contains('{n}'));
  });

  test('en-US meal_plan and meal_detail keys exist', () async {
    final en = await loadLocale('en-US.json');
    final mealPlan = en['meal_plan'] as Map<String, dynamic>;
    final mealDetail = en['meal_detail'] as Map<String, dynamic>;

    expect(mealPlan['title'], 'Meal Plan');
    expect(mealPlan['swap_title'], 'Swap meal');
    expect(mealDetail['tab_nutrition'], 'Nutrition');
    expect(mealDetail['snack_have_all'], isNotEmpty);
  });
}
