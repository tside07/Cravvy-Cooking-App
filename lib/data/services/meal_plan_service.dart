// CRUD cho bảng meal_plans.
// Tuần 5: AI Edge Function insert vào bảng này — không cần đổi gì ở đây.

import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

class MealPlanEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final String recipeId;
  final bool isLogged;

  const MealPlanEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.isLogged,
  });

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => MealPlanEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    date: DateTime.parse(json['date'] as String),
    mealType: json['meal_type'] as String,
    recipeId: json['recipe_id'] as String,
    isLogged: json['is_logged'] as bool? ?? false,
  );
}

class MealPlanService {
  static final _client = SupabaseService.client;
  static const _table = 'meal_plans';

  static String dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Fetch 7 ngày của tuần
  static Future<List<MealPlanEntry>> fetchWeek({
    required String userId,
    required DateTime weekStart,
  }) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gte('date', dateStr(weekStart))
        .lte('date', dateStr(weekEnd))
        .order('date')
        .order('meal_type');
    return (data as List).map((e) => MealPlanEntry.fromJson(e)).toList();
  }

  // Thêm hoặc ghi đè slot
  static Future<MealPlanEntry?> addMeal({
    required String userId,
    required DateTime date,
    required String mealType,
    required String recipeId,
  }) async {
    final data = await _client
        .from(_table)
        .upsert({
          'user_id': userId,
          'date': dateStr(date),
          'meal_type': mealType,
          'recipe_id': recipeId,
          'is_logged': false,
        }, onConflict: 'user_id,date,meal_type')
        .select()
        .single();
    return MealPlanEntry.fromJson(data);
  }

  // Xóa slot
  static Future<void> removeMeal({
    required String userId,
    required DateTime date,
    required String mealType,
  }) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('date', dateStr(date))
        .eq('meal_type', mealType);
  }

  // Toggle is_logged
  static Future<void> toggleLogged({
    required String entryId,
    required bool isLogged,
  }) async {
    await _client
        .from(_table)
        .update({'is_logged': isLogged})
        .eq('id', entryId);
  }

  // Swap recipe, reset logged
  static Future<void> swapMeal({
    required String entryId,
    required String newRecipeId,
  }) async {
    await _client
        .from(_table)
        .update({'recipe_id': newRecipeId, 'is_logged': false})
        .eq('id', entryId);
  }
}
