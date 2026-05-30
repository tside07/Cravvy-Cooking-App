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

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        recipeName: json['recipeName'] as String,
        recipeId: json['recipeId'] as String,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'recipeName': recipeName,
        'recipeId': recipeId,
        'checked': checked,
      };

  String get displayLabel =>
      name.trim().isEmpty ? recipeName : name.trim();
}
