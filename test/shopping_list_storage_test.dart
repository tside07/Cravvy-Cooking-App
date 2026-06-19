import 'package:cravvy_cooking_app/data/services/shopping_list_storage.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guest and users use separate storage keys', () async {
    final guestItem = ShoppingItem(
      id: 'guest-1',
      name: 'guest item',
      recipeName: 'Guest',
      recipeId: 'r-guest',
    );
    final userItem = ShoppingItem(
      id: 'user-1',
      name: 'user item',
      recipeName: 'User',
      recipeId: 'r-user',
    );

    await ShoppingListStorage.save([guestItem], userId: null);
    await ShoppingListStorage.save([userItem], userId: 'user-a');

    final guestLoaded = await ShoppingListStorage.load(userId: null);
    final userLoaded = await ShoppingListStorage.load(userId: 'user-a');
    final otherUserLoaded = await ShoppingListStorage.load(userId: 'user-b');

    expect(guestLoaded, hasLength(1));
    expect(guestLoaded.first.id, 'guest-1');
    expect(userLoaded, hasLength(1));
    expect(userLoaded.first.id, 'user-1');
    expect(otherUserLoaded, isEmpty);
  });

  test('keyForUser encodes user id in storage key', () {
    expect(
      ShoppingListStorage.keyForUser('abc-123'),
      contains('abc-123'),
    );
    expect(
      ShoppingListStorage.keyForUser(null),
      endsWith('_guest'),
    );
  });
}
