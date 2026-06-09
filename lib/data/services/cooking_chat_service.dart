import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Typed failure kinds surfaced to the chat UI.
enum ChatErrorKind { dailyLimit, busy, network, failed }

class CookingChatException implements Exception {
  CookingChatException(this.kind, {this.message, this.retryAfterSeconds});

  final ChatErrorKind kind;
  final String? message;
  final int? retryAfterSeconds;

  @override
  String toString() => 'CookingChatException($kind): $message';
}

/// Result of a successful `cooking-chat` invocation.
class ChatReply {
  const ChatReply({
    required this.reply,
    required this.referencedRecipeIds,
    this.remainingToday,
  });

  final String reply;
  final List<String> referencedRecipeIds;
  final int? remainingToday;
}

/// Talks to the `cooking-chat` Edge Function and reads chat history.
class CookingChatService {
  static const _functionName = 'cooking-chat';
  static const _table = 'chat_messages';
  static const _timeout = Duration(seconds: 45);

  /// Sends [history] (oldest→newest, last item must be the user's message) and
  /// returns the assistant reply. Throws [CookingChatException] on failure.
  static Future<ChatReply> send({
    required List<ChatMessage> history,
    bool includeWeekPlan = false,
    String locale = 'en',
  }) async {
    try {
      final response = await SupabaseService.client.functions
          .invoke(
            _functionName,
            body: {
              'messages': history.map((m) => m.toRequestJson()).toList(),
              'include_week_plan': includeWeekPlan,
              'locale': locale,
            },
          )
          .timeout(_timeout);

      return parseResponse(response.data);
    } on CookingChatException {
      rethrow;
    } catch (e) {
      throw CookingChatException(ChatErrorKind.network, message: e.toString());
    }
  }

  /// Maps the Edge Function payload to a [ChatReply], or throws a typed
  /// [CookingChatException]. Pure — safe to unit test.
  static ChatReply parseResponse(dynamic data) {
    if (data is! Map) {
      throw CookingChatException(ChatErrorKind.failed,
          message: 'Invalid response');
    }

    final error = data['error'];
    if (error != null) {
      switch (error.toString()) {
        case 'daily_limit':
          throw CookingChatException(ChatErrorKind.dailyLimit);
        case 'busy':
          throw CookingChatException(
            ChatErrorKind.busy,
            retryAfterSeconds: (data['retry_after'] as num?)?.toInt(),
          );
        default:
          throw CookingChatException(ChatErrorKind.failed,
              message: error.toString());
      }
    }

    return ChatReply(
      reply: data['reply'] as String? ?? '',
      referencedRecipeIds:
          (data['referenced_recipe_ids'] as List<dynamic>?)?.cast<String>() ??
              const [],
      remainingToday: (data['remaining_today'] as num?)?.toInt(),
    );
  }

  /// Loads the most recent [limit] messages, returned oldest→newest.
  static Future<List<ChatMessage>> fetchHistory({int limit = 40}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final data = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    final list = (data as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    return list.reversed.toList();
  }
}
