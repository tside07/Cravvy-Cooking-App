import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/services/cooking_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CookingChatService.parseResponse', () {
    test('parses a successful reply with referenced recipes', () {
      final reply = CookingChatService.parseResponse({
        'reply': 'Try this dish!',
        'referenced_recipe_ids': ['a', 'b'],
        'remaining_today': 9,
      });

      expect(reply.reply, 'Try this dish!');
      expect(reply.referencedRecipeIds, ['a', 'b']);
      expect(reply.remainingToday, 9);
    });

    test('defaults missing optional fields', () {
      final reply = CookingChatService.parseResponse({'reply': 'Hi'});
      expect(reply.referencedRecipeIds, isEmpty);
      expect(reply.remainingToday, isNull);
    });

    test('maps daily_limit error', () {
      expect(
        () => CookingChatService.parseResponse({'error': 'daily_limit'}),
        throwsA(
          isA<CookingChatException>()
              .having((e) => e.kind, 'kind', ChatErrorKind.dailyLimit),
        ),
      );
    });

    test('maps busy error with retry_after', () {
      expect(
        () => CookingChatService.parseResponse({
          'error': 'busy',
          'retry_after': 8,
        }),
        throwsA(
          isA<CookingChatException>()
              .having((e) => e.kind, 'kind', ChatErrorKind.busy)
              .having((e) => e.retryAfterSeconds, 'retryAfter', 8),
        ),
      );
    });

    test('maps unknown error to failed', () {
      expect(
        () => CookingChatService.parseResponse({'error': 'boom'}),
        throwsA(
          isA<CookingChatException>()
              .having((e) => e.kind, 'kind', ChatErrorKind.failed),
        ),
      );
    });

    test('rejects non-map payloads', () {
      expect(
        () => CookingChatService.parseResponse('nope'),
        throwsA(isA<CookingChatException>()),
      );
    });
  });

  group('ChatMessage', () {
    test('fromJson parses a stored row', () {
      final msg = ChatMessage.fromJson({
        'role': 'assistant',
        'content': 'hello',
        'referenced_recipe_ids': ['x'],
        'created_at': '2026-06-07T10:00:00Z',
      });

      expect(msg.role, ChatRole.assistant);
      expect(msg.content, 'hello');
      expect(msg.referencedRecipeIds, ['x']);
      expect(msg.createdAt, isNotNull);
    });

    test('toRequestJson keeps only role + content', () {
      final json = const ChatMessage(role: ChatRole.user, content: 'hi')
          .toRequestJson();
      expect(json, {'role': 'user', 'content': 'hi'});
    });
  });
}
