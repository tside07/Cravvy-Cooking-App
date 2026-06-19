import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';

/// Parses recipe ingredient strings into [MealDetailIngredient] rows.
///
/// Seed data uses plain names ("ức gà"); imports may use "200g chicken".
abstract final class RecipeIngredientParser {
  static final _quantityPrefix = RegExp(
    r'^(\d+(?:[.,]\d+)?\s*(?:g|kg|ml|l|cup|cups|tbsp|tsp|oz|lb|cloves?|slices?|pieces?|pinch|handful|medium|large|small)?)\s+(.+)$',
    caseSensitive: false,
  );

  static List<MealDetailIngredient> parseAll(List<String> raw) {
    if (raw.isEmpty) return const [];
    return raw
        .map((line) => parseLine(line.trim()))
        .where((i) => i.name.isNotEmpty)
        .toList(growable: false);
  }

  static MealDetailIngredient parseLine(String line) {
    if (line.isEmpty) {
      return const MealDetailIngredient(name: '', quantity: '');
    }

    final match = _quantityPrefix.firstMatch(line);
    if (match != null) {
      return MealDetailIngredient(
        quantity: match.group(1)!.trim(),
        name: match.group(2)!.trim(),
      );
    }

    return MealDetailIngredient(
      quantity: '',
      name: line,
    );
  }
}
