import 'package:cravvy_cooking_app/data/services/shopping_list_storage.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ShoppingListProvider extends ChangeNotifier {
  ShoppingListProvider({bool autoLoad = true}) {
    if (autoLoad) _load();
  }

  static const _uuid = Uuid();

  final List<ShoppingItem> _items = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<ShoppingItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get checkedCount => _items.where((i) => i.checked).length;
  int get totalCount => _items.length;

  double get progress => _items.isEmpty ? 0 : checkedCount / _items.length;

  Map<String, List<ShoppingItem>> get grouped {
    final map = <String, List<ShoppingItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.recipeId, () => []).add(item);
    }
    return map;
  }

  /// Distinct recipe ids in insertion order (for the cart list).
  List<String> get recipeIds {
    final seen = <String>[];
    for (final item in _items) {
      if (!seen.contains(item.recipeId)) seen.add(item.recipeId);
    }
    return seen;
  }

  List<ShoppingItem> itemsForRecipe(String recipeId) =>
      _items.where((i) => i.recipeId == recipeId).toList();

  int checkedCountForRecipe(String recipeId) =>
      _items.where((i) => i.recipeId == recipeId && i.checked).length;

  int totalCountForRecipe(String recipeId) =>
      _items.where((i) => i.recipeId == recipeId).length;

  String recipeNameOf(String recipeId) {
    final match = _items.where((i) => i.recipeId == recipeId);
    if (match.isEmpty) return '';
    return match.first.recipeName;
  }

  Future<void> _load() async {
    final stored = await ShoppingListStorage.load();
    _items
      ..clear()
      ..addAll(stored);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() => ShoppingListStorage.save(_items);

  /// Adds unchecked ingredients from meal detail. Returns count added (skips dupes).
  int addFromMeal({
    required String recipeId,
    required String recipeName,
    required List<MealDetailIngredient> ingredients,
  }) {
    var added = 0;
    for (final ingredient in ingredients) {
      final label = _ingredientLabel(ingredient);
      if (label.isEmpty) continue;
      if (_hasDuplicate(recipeId, label)) continue;

      _items.add(
        ShoppingItem(
          id: _uuid.v4(),
          name: label,
          recipeName: recipeName,
          recipeId: recipeId,
        ),
      );
      added++;
    }

    if (added > 0) {
      notifyListeners();
      _persist();
    }
    return added;
  }

  String _ingredientLabel(MealDetailIngredient ingredient) {
    final q = ingredient.quantity.trim();
    final n = ingredient.name.trim();
    if (q.isEmpty) return n;
    if (n.isEmpty) return q;
    return '$q $n';
  }

  bool _hasDuplicate(String recipeId, String label) {
    final normalized = label.toLowerCase();
    return _items.any(
      (i) =>
          i.recipeId == recipeId &&
          i.displayLabel.toLowerCase() == normalized,
    );
  }

  void toggle(String id) {
    final item = _items.firstWhere((i) => i.id == id);
    item.checked = !item.checked;
    notifyListeners();
    _persist();
  }

  void increment(String id) {
    final item = _items.firstWhere((i) => i.id == id);
    item.quantity += 1;
    notifyListeners();
    _persist();
  }

  void decrement(String id) {
    final item = _items.firstWhere((i) => i.id == id);
    if (item.quantity <= 1) return;
    item.quantity -= 1;
    notifyListeners();
    _persist();
  }

  /// Marks every ingredient of a recipe as bought (checked).
  void markRecipeBought(String recipeId) {
    for (final item in _items.where((i) => i.recipeId == recipeId)) {
      item.checked = true;
    }
    notifyListeners();
    _persist();
  }

  /// Removes all ingredients belonging to a recipe.
  void removeRecipe(String recipeId) {
    _items.removeWhere((i) => i.recipeId == recipeId);
    notifyListeners();
    _persist();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    _persist();
  }

  void clearChecked() {
    _items.removeWhere((i) => i.checked);
    notifyListeners();
    _persist();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
    _persist();
  }
}
