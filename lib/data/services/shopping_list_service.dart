import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';

/// Supabase CRUD for [shopping_list_items] (per authenticated user).
abstract final class ShoppingListService {
  static final _client = SupabaseService.client;
  static const _table = 'shopping_list_items';

  static Future<List<ShoppingItem>> fetchForUser(String userId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('updated_at');
    return (data as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Replaces all rows for [userId] with [items] (full sync after local edits).
  static Future<void> replaceAll(
    String userId,
    List<ShoppingItem> items,
  ) async {
    await _client.from(_table).delete().eq('user_id', userId);
    if (items.isEmpty) return;

    final rows = items.map((i) => _toRow(userId, i)).toList();
    await _client.from(_table).insert(rows);
  }

  static ShoppingItem _fromRow(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        recipeName: json['recipe_name'] as String,
        recipeId: json['recipe_id'] as String,
        checked: json['checked'] as bool? ?? false,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );

  static Map<String, dynamic> _toRow(String userId, ShoppingItem item) => {
        'id': item.id,
        'user_id': userId,
        'recipe_id': item.recipeId,
        'recipe_name': item.recipeName,
        'name': item.name,
        'checked': item.checked,
        'quantity': item.quantity,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
}
