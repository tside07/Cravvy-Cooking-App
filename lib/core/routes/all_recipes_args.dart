/// Navigation extras for [AllRecipesScreen] (`/recipes/all`).
class AllRecipesArgs {
  const AllRecipesArgs({
    this.initialMealType = 'all',
    this.initialSearchQuery,
  });

  /// `all` | `breakfast` | `lunch` | `dinner` | `snack`
  final String initialMealType;

  final String? initialSearchQuery;
}
