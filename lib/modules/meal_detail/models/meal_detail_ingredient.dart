/// Availability status of an ingredient in the user's pantry.
enum IngredientStatus {
  /// The ingredient is available (green check).
  available,

  /// The ingredient is missing (orange warning).
  missing,
}

class MealDetailIngredient {
  final String name;
  final String quantity;
  final IngredientStatus status;

  const MealDetailIngredient({
    required this.name,
    required this.quantity,
    this.status = IngredientStatus.available,
  });
}
