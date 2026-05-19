import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';

class ShoppingListProvider extends ChangeNotifier {
  final List<ShoppingItem> _items = [
    ShoppingItem(
      id: '1',
      name: '2 salmon fillets (150g each)',
      recipeName: 'Baked Salmon',
      recipeId: 'r1',
    ),
    ShoppingItem(
      id: '2',
      name: '200g broccoli florets',
      recipeName: 'Baked Salmon',
      recipeId: 'r1',
    ),
    ShoppingItem(
      id: '3',
      name: '1 lemon',
      recipeName: 'Baked Salmon',
      recipeId: 'r1',
    ),
    ShoppingItem(
      id: '4',
      name: '3 garlic cloves',
      recipeName: 'Baked Salmon',
      recipeId: 'r1',
    ),
    ShoppingItem(
      id: '5',
      name: '2 cups oats',
      recipeName: 'Overnight Oats',
      recipeId: 'r2',
    ),
    ShoppingItem(
      id: '6',
      name: '1 cup almond milk',
      recipeName: 'Overnight Oats',
      recipeId: 'r2',
    ),
    ShoppingItem(
      id: '7',
      name: '2 tbsp chia seeds',
      recipeName: 'Overnight Oats',
      recipeId: 'r2',
    ),
    ShoppingItem(
      id: '8',
      name: '1 banana',
      recipeName: 'Overnight Oats',
      recipeId: 'r2',
    ),
  ];

  // ─── Getters ──────────────────────────────────────────────────────────────

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

  String recipeNameOf(String recipeId) => _items
      .firstWhere((i) => i.recipeId == recipeId, orElse: () => _items.first)
      .recipeName;

  // ─── Actions ──────────────────────────────────────────────────────────────

  void toggle(String id) {
    final item = _items.firstWhere((i) => i.id == id);
    item.checked = !item.checked;
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearChecked() {
    _items.removeWhere((i) => i.checked);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
