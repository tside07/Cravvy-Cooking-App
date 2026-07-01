import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/models/chat_session.dart';
import 'package:cravvy_cooking_app/data/services/chat_session_storage.dart';
import 'package:cravvy_cooking_app/data/services/cooking_chat_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Drives the AI chat screen: multiple conversations (sessions) across several
/// assistants, optimistic send, typing state, spam cooldown, typed errors, and
/// local persistence. On first run it migrates any existing remote history into
/// a default AI Chef session.
class ChatProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  static const _cooldown = Duration(seconds: 2);

  final List<ChatSession> _sessions = [];
  String? _currentId;

  bool _isInitializing = false;
  bool _isSending = false;
  bool _ready = false;
  int? _remainingToday;
  CookingChatException? _lastError;
  DateTime? _lastSentAt;

  // ─── Reads ─────────────────────────────────────────────────────────────────

  bool get isInitializing => _isInitializing;
  bool get isSending => _isSending;
  bool get isReady => _ready;
  int? get remainingToday => _remainingToday;
  CookingChatException? get lastError => _lastError;

  ChatSession? get currentSession {
    for (final s in _sessions) {
      if (s.id == _currentId) return s;
    }
    return null;
  }

  ChatAssistant get currentAssistant =>
      currentSession?.assistant ?? ChatAssistant.aiChef;

  List<ChatMessage> get messages =>
      List.unmodifiable(currentSession?.messages ?? const <ChatMessage>[]);

  bool get isEmpty => messages.isEmpty;

  /// Non-empty conversations, newest first — the menu drawer "recent chats".
  List<ChatSession> get recentSessions {
    final list = _sessions.where((s) => !s.isEmpty).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  bool get canSend {
    if (_isSending) return false;
    final last = _lastSentAt;
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return false;
    }
    return true;
  }

  String? get _userId => SupabaseService.currentUser?.id;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  /// Loads stored sessions; on first run, migrates remote history; always
  /// leaves a current session selected. Safe to call more than once.
  Future<void> init() async {
    if (_ready || _isInitializing) return;
    _isInitializing = true;
    notifyListeners();

    try {
      final stored = await ChatSessionStorage.load(userId: _userId);
      _sessions
        ..clear()
        ..addAll(stored);

      if (_sessions.isEmpty) {
        await _migrateRemoteHistory();
      }
    } catch (e) {
      // Non-fatal: fall through to an empty default session; log để biết nếu
      // việc nạp/migrate lịch sử chat thất bại (tránh mất dữ liệu âm thầm).
      if (kDebugMode) debugPrint('ChatProvider.init load/migrate failed: $e');
    } finally {
      if (_sessions.isEmpty) {
        _sessions.add(_blankSession(ChatAssistant.aiChef));
      }
      _selectMostRecent();
      _ready = true;
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Pulls the legacy flat `chat_messages` history into one AI Chef session.
  Future<void> _migrateRemoteHistory() async {
    final history = await CookingChatService.fetchHistory();
    if (history.isEmpty) return;

    final created = history.first.createdAt ?? DateTime.now();
    final updated = history.last.createdAt ?? DateTime.now();
    final session = ChatSession(
      id: _uuid.v4(),
      assistant: ChatAssistant.aiChef,
      messages: List.of(history),
      createdAt: created,
      updatedAt: updated,
    );
    session.title = session.derivedTitle;
    _sessions.add(session);
    await _persist();
  }

  // ─── Conversation management ─────────────────────────────────────────────────

  /// Switches to the most recent conversation with the given assistant, or
  /// starts a fresh one if there is none.
  void selectAssistant(ChatAssistant assistant) {
    ChatSession? latest;
    for (final s in _sessions) {
      if (s.assistant != assistant || s.isEmpty) continue;
      if (latest == null || s.updatedAt.isAfter(latest.updatedAt)) {
        latest = s;
      }
    }
    if (latest != null) {
      _currentId = latest.id;
      notifyListeners();
    } else {
      newChat(assistant);
    }
  }

  /// Starts a new (empty) conversation and makes it current.
  void newChat([ChatAssistant? assistant]) {
    final a = assistant ?? currentAssistant;
    // Reuse an existing blank session for this assistant if one is idle.
    for (final s in _sessions) {
      if (s.assistant == a && s.isEmpty) {
        _currentId = s.id;
        notifyListeners();
        return;
      }
    }
    final session = _blankSession(a);
    _sessions.add(session);
    _currentId = session.id;
    notifyListeners();
  }

  void switchSession(String id) {
    if (_currentId == id) return;
    _currentId = id;
    notifyListeners();
  }

  Future<void> renameSession(String id, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    for (final s in _sessions) {
      if (s.id == id) {
        s.title = trimmed;
        break;
      }
    }
    notifyListeners();
    await _persist();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    if (_currentId == id) {
      _selectMostRecent();
    }
    notifyListeners();
    await _persist();
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  // ─── Send ──────────────────────────────────────────────────────────────────

  /// Appends [text] to the current session optimistically and requests a reply.
  Future<void> send(String text, {required String locale}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !canSend) return;

    final session = currentSession;
    if (session == null) return;

    _lastError = null;
    _lastSentAt = DateTime.now();
    session.messages.add(
      ChatMessage(
        role: ChatRole.user,
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    session.title ??= session.derivedTitle;
    session.updatedAt = DateTime.now();
    _isSending = true;
    notifyListeners();

    try {
      final reply = await CookingChatService.send(
        history: session.messages,
        includeWeekPlan: session.assistant.includeWeekPlan,
        locale: locale,
      );
      session.messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply.reply,
          referencedRecipeIds: reply.referencedRecipeIds,
          createdAt: DateTime.now(),
        ),
      );
      session.updatedAt = DateTime.now();
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
      unawaited(_persist());
    }
  }

  // ─── Internals ───────────────────────────────────────────────────────────────

  ChatSession _blankSession(ChatAssistant assistant) {
    final now = DateTime.now();
    return ChatSession(
      id: _uuid.v4(),
      assistant: assistant,
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Selects the most recently updated non-empty session, falling back to any
  /// session, and finally to a fresh AI Chef session.
  void _selectMostRecent() {
    ChatSession? best;
    for (final s in _sessions) {
      if (s.isEmpty) continue;
      if (best == null || s.updatedAt.isAfter(best.updatedAt)) best = s;
    }
    best ??= _sessions.isNotEmpty ? _sessions.first : null;
    if (best == null) {
      final blank = _blankSession(ChatAssistant.aiChef);
      _sessions.add(blank);
      best = blank;
    }
    _currentId = best.id;
  }

  /// Persists only non-empty sessions so storage stays clean.
  Future<void> _persist() async {
    final durable = _sessions.where((s) => !s.isEmpty).toList();
    try {
      await ChatSessionStorage.save(durable, userId: _userId);
    } catch (_) {
      // Best-effort; ignore local write failures.
    }
  }
}
