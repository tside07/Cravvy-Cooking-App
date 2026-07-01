import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cravvy_cooking_app/core/constants/app_constants.dart';
import 'package:cravvy_cooking_app/data/models/chat_session.dart';

/// Persists chat sessions (conversations) locally between app launches.
/// Each user (or guest) has an isolated storage key, mirroring
/// [ShoppingListStorage].
abstract final class ChatSessionStorage {
  static String keyForUser(String? userId) => userId == null
      ? '${AppConst.keyChatSessions}_guest'
      : '${AppConst.keyChatSessions}_$userId';

  static Future<List<ChatSession>> load({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyForUser(userId));
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(
    List<ChatSession> sessions, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(keyForUser(userId), encoded);
  }
}
