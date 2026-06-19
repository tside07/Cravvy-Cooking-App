import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShoppingListProvider', () {
    test('addFromMeal skips duplicates for same recipe', () {
      final provider = ShoppingListProvider(autoLoad: false);
      const ingredients = [
        MealDetailIngredient(name: 'ức gà', quantity: '200g'),
        MealDetailIngredient(name: 'hành lá', quantity: ''),
      ];

      final first = provider.addFromMeal(
        recipeId: 'r1',
        recipeName: 'Phở gà',
        ingredients: ingredients,
      );
      final second = provider.addFromMeal(
        recipeId: 'r1',
        recipeName: 'Phở gà',
        ingredients: ingredients,
      );

      expect(first, 2);
      expect(second, 0);
      expect(provider.totalCount, 2);
    });

    test('clearChecked removes only checked items', () {
      final provider = ShoppingListProvider(autoLoad: false);
      provider.addFromMeal(
        recipeId: 'r1',
        recipeName: 'Test',
        ingredients: const [
          MealDetailIngredient(name: 'a', quantity: ''),
          MealDetailIngredient(name: 'b', quantity: ''),
        ],
      );

      final id = provider.items.first.id;
      provider.toggle(id);
      provider.clearChecked();

      expect(provider.totalCount, 1);
      expect(provider.items.first.name, 'b');
    });
  });
}
