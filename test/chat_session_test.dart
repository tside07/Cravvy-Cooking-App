import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/models/chat_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage.toJson', () {
    test('round-trips through fromJson', () {
      final original = ChatMessage(
        role: ChatRole.assistant,
        content: 'Try roasted carrots',
        referencedRecipeIds: const ['r1', 'r2'],
        createdAt: DateTime.parse('2026-06-07T10:00:00.000Z'),
      );

      final restored = ChatMessage.fromJson(original.toJson());

      expect(restored.role, ChatRole.assistant);
      expect(restored.content, 'Try roasted carrots');
      expect(restored.referencedRecipeIds, ['r1', 'r2']);
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('ChatAssistant', () {
    test('id is stable and round-trips via fromId', () {
      for (final a in ChatAssistant.values) {
        expect(ChatAssistant.fromId(a.id), a);
      }
    });

    test('unknown id falls back to AI Chef', () {
      expect(ChatAssistant.fromId('does_not_exist'), ChatAssistant.aiChef);
      expect(ChatAssistant.fromId(null), ChatAssistant.aiChef);
    });

    test('only Meal Planner sends the week plan as context', () {
      expect(ChatAssistant.mealPlanner.includeWeekPlan, isTrue);
      expect(ChatAssistant.aiChef.includeWeekPlan, isFalse);
      expect(ChatAssistant.nutritionCoach.includeWeekPlan, isFalse);
      expect(ChatAssistant.pantryHelper.includeWeekPlan, isFalse);
    });
  });

  group('ChatSession', () {
    test('toJson round-trips through fromJson', () {
      final session = ChatSession(
        id: 'abc',
        assistant: ChatAssistant.nutritionCoach,
        title: 'Macro chat',
        createdAt: DateTime.parse('2026-06-07T09:00:00.000Z'),
        updatedAt: DateTime.parse('2026-06-07T09:05:00.000Z'),
        messages: [
          ChatMessage(
            role: ChatRole.user,
            content: 'How much protein?',
            createdAt: DateTime.parse('2026-06-07T09:00:00.000Z'),
          ),
          ChatMessage(
            role: ChatRole.assistant,
            content: 'Aim for ~1.6g/kg.',
            createdAt: DateTime.parse('2026-06-07T09:05:00.000Z'),
          ),
        ],
      );

      final restored = ChatSession.fromJson(session.toJson());

      expect(restored.id, 'abc');
      expect(restored.assistant, ChatAssistant.nutritionCoach);
      expect(restored.title, 'Macro chat');
      expect(restored.createdAt, session.createdAt);
      expect(restored.updatedAt, session.updatedAt);
      expect(restored.messages.length, 2);
      expect(restored.messages.first.content, 'How much protein?');
    });

    test('derivedTitle uses the first user message, truncated', () {
      final session = ChatSession(
        id: '1',
        assistant: ChatAssistant.aiChef,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        messages: [
          const ChatMessage(role: ChatRole.assistant, content: 'Hi there'),
          const ChatMessage(
            role: ChatRole.user,
            content:
                'Can you suggest a high protein dinner that is quick to make tonight please',
          ),
        ],
      );

      final title = session.derivedTitle!;
      expect(title.startsWith('Can you suggest a high protein'), isTrue);
      expect(title.endsWith('…'), isTrue);
      expect(title.length, lessThanOrEqualTo(43));
    });

    test('isEmpty reflects message presence', () {
      final empty = ChatSession(
        id: '2',
        assistant: ChatAssistant.aiChef,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        messages: [],
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.derivedTitle, isNull);
    });
  });
}
