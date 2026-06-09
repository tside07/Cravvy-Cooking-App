import 'package:flutter/foundation.dart';

import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/services/cooking_chat_service.dart';

/// Drives the AI cooking chat screen: history load, optimistic send,
/// typing state, spam cooldown, and typed error handling.
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoadingHistory = false;
  bool _isSending = false;
  int? _remainingToday;
  CookingChatException? _lastError;
  DateTime? _lastSentAt;

  static const _cooldown = Duration(seconds: 2);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSending => _isSending;
  bool get isEmpty => _messages.isEmpty;
  int? get remainingToday => _remainingToday;
  CookingChatException? get lastError => _lastError;

  bool get canSend {
    if (_isSending) return false;
    final last = _lastSentAt;
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return false;
    }
    return true;
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final history = await CookingChatService.fetchHistory();
      _messages
        ..clear()
        ..addAll(history);
    } catch (_) {
      // Non-fatal: start with an empty thread.
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  /// Appends the user message optimistically and requests a reply.
  Future<void> send(String text, {required String locale}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !canSend) return;

    _lastError = null;
    _lastSentAt = DateTime.now();
    _messages.add(ChatMessage(role: ChatRole.user, content: trimmed));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await CookingChatService.send(
        history: _messages,
        locale: locale,
      );
      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply.reply,
          referencedRecipeIds: reply.referencedRecipeIds,
        ),
      );
      _remainingToday = reply.remainingToday;
    } on CookingChatException catch (e) {
      _lastError = e;
    } catch (e) {
      _lastError = CookingChatException(
        ChatErrorKind.failed,
        message: e.toString(),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
