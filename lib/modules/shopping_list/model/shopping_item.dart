class ShoppingItem {
  final String id;
  final String name;
  final String recipeName;
  final String recipeId;
  bool checked;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.recipeName,
    required this.recipeId,
    this.checked = false,
  });
}
