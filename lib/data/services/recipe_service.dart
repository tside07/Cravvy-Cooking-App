// lib/data/services/recipe_service.dart

import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';

class RecipeService {
  static final _client = SupabaseService.client;
  static const _table = 'recipes';

  // ─── Lấy tất cả recipes (dùng cho Home - featured) ───────────────────────
  static Future<List<Recipe>> fetchAll({int limit = 20}) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('created_at')
        .limit(limit);

    return (data as List).map((e) => Recipe.fromJson(e)).toList();
  }

  // ─── Lấy theo meal_type (breakfast / lunch / dinner / snack) ─────────────
  static Future<List<Recipe>> fetchByMealType(
    String mealType, {
    int limit = 10,
  }) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .eq('meal_type', mealType)
        .order('created_at')
        .limit(limit);

    return (data as List).map((e) => Recipe.fromJson(e)).toList();
  }

  // ─── Lấy 1 recipe theo ID ─────────────────────────────────────────────────
  static Future<Recipe?> fetchById(String id) async {
    final data = await _client.from(_table).select().eq('id', id).maybeSingle();

    if (data == null) return null;
    return Recipe.fromJson(data);
  }

  // ─── Tìm kiếm theo tên ────────────────────────────────────────────────────
  static Future<List<Recipe>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    final data = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .ilike('name', '%${query.trim()}%')
        .order('calories')
        .limit(limit);

    return (data as List).map((e) => Recipe.fromJson(e)).toList();
  }

  // ─── Lấy recipes theo tag ─────────────────────────────────────────────────
  // Supabase PostgreSQL array overlap operator
  static Future<List<Recipe>> fetchByTag(String tag, {int limit = 10}) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .contains('tags', [tag])
        .limit(limit);

    return (data as List).map((e) => Recipe.fromJson(e)).toList();
  }

  // ─── Lấy recipes phù hợp với user preference ─────────────────────────────
  // Dùng khi AI chưa có — filter thủ công theo goal + diet
  static Future<List<Recipe>> fetchForUser({
    String? goal,
    List<String> diets = const [],
    int calorieMax = 700,
    int limit = 20,
  }) async {
    var query = _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .lte('calories', calorieMax);

    // Filter tag theo goal
    if (goal == 'lose-weight') {
      // Không filter thêm — calories cap đã đủ
    } else if (goal == 'build-muscle') {
      query = query.gte('protein', 25);
    }

    final data = await query.order('calories').limit(limit);
    return (data as List).map((e) => Recipe.fromJson(e)).toList();
  }
}
