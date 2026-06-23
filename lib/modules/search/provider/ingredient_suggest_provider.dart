import 'package:flutter/foundation.dart';

import 'package:cravvy_cooking_app/data/models/ingredient_suggestion.dart';
import 'package:cravvy_cooking_app/data/services/ingredient_suggest_service.dart';

enum SuggestStatus { idle, loading, loaded, error }

/// Drives the "Cook from my ingredients" AI flow on the Search > Type tab.
class IngredientSuggestProvider extends ChangeNotifier {
  SuggestStatus _status = SuggestStatus.idle;
  List<IngredientSuggestion> _suggestions = [];
  bool _aiUnavailable = false;
  bool _sufficient = true;
  IngredientSuggestException? _lastError;

  SuggestStatus get status => _status;
  List<IngredientSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isLoading => _status == SuggestStatus.loading;
  bool get hasResults => _suggestions.isNotEmpty;

  /// True when results came from the DB fallback because Gemini was skipped
  /// (quota/429). UI shows a "try again later" note above the results.
  bool get aiUnavailable => _aiUnavailable;

  /// False when the provided ingredients were too few/plain for confident,
  /// accurate suggestions. UI shows a low-confidence note above results.
  bool get sufficient => _sufficient;
  IngredientSuggestException? get lastError => _lastError;

  void clear() {
    _status = SuggestStatus.idle;
    _suggestions = [];
    _aiUnavailable = false;
    _sufficient = true;
    _lastError = null;
    notifyListeners();
  }

  Future<void> suggest({
    required List<String> ingredients,
    required String locale,
  }) async {
    if (ingredients.isEmpty || _status == SuggestStatus.loading) return;

    _status = SuggestStatus.loading;
    _lastError = null;
    notifyListeners();

    try {
      final result = await IngredientSuggestService.suggest(
        ingredients: ingredients,
        locale: locale,
      );
      _suggestions = result.suggestions;
      _aiUnavailable = result.aiUnavailable;
      _sufficient = result.sufficient;
      _status = SuggestStatus.loaded;
    } on IngredientSuggestException catch (e) {
      _lastError = e;
      _suggestions = [];
      _aiUnavailable = false;
      _status = SuggestStatus.error;
    } catch (e) {
      _lastError = IngredientSuggestException(
        SuggestErrorKind.failed,
        message: e.toString(),
      );
      _suggestions = [];
      _status = SuggestStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
