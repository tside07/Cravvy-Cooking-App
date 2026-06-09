import 'package:cravvy_cooking_app/data/services/shopping_list_service.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dedupeById keeps first occurrence only', () {
    final items = [
      ShoppingItem(
        id: 'dup',
        name: 'first',
        recipeName: 'A',
        recipeId: 'r1',
      ),
      ShoppingItem(
        id: 'dup',
        name: 'second',
        recipeName: 'A',
        recipeId: 'r1',
      ),
      ShoppingItem(
        id: 'unique',
        name: 'only',
        recipeName: 'B',
        recipeId: 'r2',
      ),
    ];

    final deduped = ShoppingListService.dedupeById(items);

    expect(deduped, hasLength(2));
    expect(deduped.first.name, 'first');
    expect(deduped.last.id, 'unique');
  });

  test('ShoppingItem round-trip matches Supabase row shape', () {
    final item = ShoppingItem(
      id: '550e8400-e29b-41d4-a716-446655440000',
      name: '200g ức gà',
      recipeName: 'Phở gà',
      recipeId: 'recipe-1',
      checked: true,
      quantity: 2,
    );

    final row = {
      'id': item.id,
      'user_id': 'user-1',
      'recipe_id': item.recipeId,
      'recipe_name': item.recipeName,
      'name': item.name,
      'checked': item.checked,
      'quantity': item.quantity,
    };

    final restored = ShoppingItem(
      id: row['id'] as String,
      name: row['name'] as String,
      recipeName: row['recipe_name'] as String,
      recipeId: row['recipe_id'] as String,
      checked: row['checked'] as bool,
      quantity: row['quantity'] as int,
    );

    expect(restored.id, item.id);
    expect(restored.displayLabel, item.displayLabel);
    expect(restored.checked, true);
    expect(restored.quantity, 2);
  });
}
