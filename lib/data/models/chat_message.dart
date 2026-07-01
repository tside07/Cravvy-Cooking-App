// lib/data/models/chat_message.dart
//
// A single turn in the AI cooking assistant conversation. Mirrors the
// `chat_messages` Supabase table; only visible text is stored.

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String content;
  final List<String> referencedRecipeIds;
  final DateTime? createdAt;

  /// True while an optimistic user message is awaiting the server reply,
  /// or while the assistant reply is being generated (typing placeholder).
  final bool isPending;

  const ChatMessage({
    required this.role,
    required this.content,
    this.referencedRecipeIds = const [],
    this.createdAt,
    this.isPending = false,
  });

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: (json['role'] as String?) == 'user'
          ? ChatRole.user
          : ChatRole.assistant,
      content: json['content'] as String? ?? '',
      referencedRecipeIds:
          (json['referenced_recipe_ids'] as List<dynamic>?)?.cast<String>() ??
              const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Payload shape expected by the `cooking-chat` Edge Function.
  Map<String, dynamic> toRequestJson() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
      };

  /// Full shape for local persistence (round-trips via [ChatMessage.fromJson]).
  Map<String, dynamic> toJson() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
        'referenced_recipe_ids': referencedRecipeIds,
        'created_at': createdAt?.toIso8601String(),
      };

  ChatMessage copyWith({
    String? content,
    List<String>? referencedRecipeIds,
    bool? isPending,
  }) {
    return ChatMessage(
      role: role,
      content: content ?? this.content,
      referencedRecipeIds: referencedRecipeIds ?? this.referencedRecipeIds,
      createdAt: createdAt,
      isPending: isPending ?? this.isPending,
    );
  }
}
