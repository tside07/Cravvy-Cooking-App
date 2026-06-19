import 'package:cravvy_cooking_app/core/utils/recipe_ingredient_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecipeIngredientParser', () {
    test('parseLine splits quantity prefix from name', () {
      final item = RecipeIngredientParser.parseLine('200g ức gà');
      expect(item.quantity, '200g');
      expect(item.name, 'ức gà');
    });

    test('parseLine keeps plain name when no quantity', () {
      final item = RecipeIngredientParser.parseLine('hành lá');
      expect(item.quantity, '');
      expect(item.name, 'hành lá');
    });

    test('parseAll filters empty lines', () {
      final list = RecipeIngredientParser.parseAll([
        '  ',
        'gạo lứt',
        '2 tbsp dầu olive',
      ]);
      expect(list.length, 2);
      expect(list.first.name, 'gạo lứt');
      expect(list.last.quantity, '2 tbsp');
      expect(list.last.name, 'dầu olive');
    });
  });
}
