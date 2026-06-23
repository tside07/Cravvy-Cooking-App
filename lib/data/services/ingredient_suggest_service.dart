import 'package:cravvy_cooking_app/data/models/ingredient_suggestion.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Typed failure kinds surfaced to the Search UI.
enum SuggestErrorKind { dailyLimit, busy, network, failed }

class IngredientSuggestException implements Exception {
  IngredientSuggestException(this.kind, {this.message});

  final SuggestErrorKind kind;
  final String? message;

  @override
  String toString() => 'IngredientSuggestException($kind): $message';
}

/// Result of a `suggest-from-ingredients` invocation.
class SuggestResult {
  const SuggestResult({
    required this.suggestions,
    required this.aiUnavailable,
    this.sufficient = true,
    this.cached = false,
    this.remainingToday,
  });

  final List<IngredientSuggestion> suggestions;

  /// True when Gemini was skipped (quota/429/limit) and results — if any —
  /// come from the DB fallback. UI shows a "try again later" note.
  final bool aiUnavailable;

  /// False when the provided ingredients were too few/plain to confidently
  /// produce accurate dishes. UI shows a low-confidence note above results.
  final bool sufficient;
  final bool cached;
  final int? remainingToday;
}

/// Talks to the `suggest-from-ingredients` Edge Function.
class IngredientSuggestService {
  static const _functionName = 'suggest-from-ingredients';
  static const _timeout = Duration(seconds: 45);

  /// Asks the server for dishes cookable from [ingredients].
  /// Throws [IngredientSuggestException] only on a hard failure with NO results
  /// (network down / server error). Quota/429 come back as a [SuggestResult]
  /// with [SuggestResult.aiUnavailable] true and DB fallback suggestions.
  static Future<SuggestResult> suggest({
    required List<String> ingredients,
    String locale = 'en',
  }) async {
    try {
      final response = await SupabaseService.client.functions
          .invoke(
            _functionName,
            body: {
              'ingredients': ingredients,
              'locale': locale,
            },
          )
          .timeout(_timeout);

      return parseResponse(response.data);
    } on IngredientSuggestException {
      rethrow;
    } catch (e) {
      throw IngredientSuggestException(
        SuggestErrorKind.network,
        message: e.toString(),
      );
    }
  }

  /// Maps the Edge Function payload to a [SuggestResult]. Pure — safe to test.
  static SuggestResult parseResponse(dynamic data) {
    if (data is! Map) {
      throw IngredientSuggestException(
        SuggestErrorKind.failed,
        message: 'Invalid response',
      );
    }

    final rawList = (data['suggestions'] as List<dynamic>?) ?? const [];
    final suggestions = rawList
        .whereType<Map<String, dynamic>>()
        .map(IngredientSuggestion.fromJson)
        .where((s) => s.name.isNotEmpty)
        .toList();

    final error = data['error'];
    // Hard failure only when the server returned NO usable results.
    if (error != null && suggestions.isEmpty) {
      switch (error.toString()) {
        case 'daily_limit':
          throw IngredientSuggestException(SuggestErrorKind.dailyLimit);
        case 'busy':
          throw IngredientSuggestException(SuggestErrorKind.busy);
        case 'ingredients required':
          throw IngredientSuggestException(
            SuggestErrorKind.failed,
            message: 'ingredients required',
          );
        default:
          throw IngredientSuggestException(
            SuggestErrorKind.failed,
            message: error.toString(),
          );
      }
    }

    return SuggestResult(
      suggestions: suggestions,
      aiUnavailable: data['ai_unavailable'] == true,
      sufficient: data['sufficient'] != false,
      cached: data['cached'] == true,
      remainingToday: (data['remaining_today'] as num?)?.toInt(),
    );
  }
}
