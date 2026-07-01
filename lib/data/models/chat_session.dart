import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/models/chat_message.dart';

/// A single conversation thread with one [ChatAssistant]. Persisted locally so
/// the menu drawer can list, rename, and delete past chats.
class ChatSession {
  ChatSession({
    required this.id,
    required this.assistant,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });

  final String id;
  final ChatAssistant assistant;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  /// User-facing label. Null until auto-derived from the first user message.
  String? title;

  bool get isEmpty => messages.isEmpty;

  /// First line of the first user message, used when [title] is unset.
  String? get derivedTitle {
    for (final m in messages) {
      if (m.isUser && m.content.trim().isNotEmpty) {
        return _summarize(m.content);
      }
    }
    return null;
  }

  static String _summarize(String text, {int maxChars = 42}) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxChars) return clean;
    return '${clean.substring(0, maxChars).trimRight()}…';
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      assistant: ChatAssistant.fromId(json['assistant'] as String?),
      title: json['title'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assistant': assistant.id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}
