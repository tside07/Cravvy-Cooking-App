import 'dart:convert';

import 'package:cravvy_cooking_app/core/constants/app_constants.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists shopping list items locally between app sessions.
/// Each user (or guest) has an isolated storage key.
abstract final class ShoppingListStorage {
  static String keyForUser(String? userId) => userId == null
      ? '${AppConst.keyShoppingList}_guest'
      : '${AppConst.keyShoppingList}_$userId';

  static Future<List<ShoppingItem>> load({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyForUser(userId));
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(
    List<ShoppingItem> items, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(keyForUser(userId), encoded);
  }
}
