import 'package:cravvy_cooking_app/core/utils/recipe_ingredient_parser.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/data/services/recipe_service.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';
import 'package:flutter/foundation.dart';

/// Which tab is active on the detail screen.
enum MealDetailTab { ingredients, nutrition, instructions }

class MealDetailProvider extends ChangeNotifier {
  MealDetailProvider(
    this.meal, {
    RecipeProvider? recipeLookup,
  }) : _recipeLookup = recipeLookup {
    _loadIngredients();
  }

  final Meal meal;
  final RecipeProvider? _recipeLookup;

  MealDetailTab _activeTab = MealDetailTab.ingredients;
  MealDetailTab get activeTab => _activeTab;

  bool _loadingIngredients = true;
  bool get loadingIngredients => _loadingIngredients;

  List<MealDetailIngredient> _ingredients = [];
  List<MealDetailIngredient> get ingredients => _ingredients;

  /// Unchecked rows = items the user still needs to buy.
  List<MealDetailIngredient> get ingredientsToShop {
    return [
      for (var i = 0; i < _ingredients.length; i++)
        if (!_checkedIds.contains(i)) _ingredients[i],
    ];
  }

  int get servings => _servings;
  int _servings = 2;

  final Set<int> _checkedIds = {};

  void selectTab(MealDetailTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  void incrementServings() {
    _servings++;
    notifyListeners();
  }

  void decrementServings() {
    if (_servings <= 1) return;
    _servings--;
    notifyListeners();
  }

  bool isChecked(int index) => _checkedIds.contains(index);

  void toggleChecked(int index) {
    if (_checkedIds.contains(index)) {
      _checkedIds.remove(index);
    } else {
      _checkedIds.add(index);
    }
    notifyListeners();
  }

  Future<void> _loadIngredients() async {
    _loadingIngredients = true;
    notifyListeners();

    final raw = await _resolveIngredientLines();
    _ingredients = RecipeIngredientParser.parseAll(raw);
    _loadingIngredients = false;
    notifyListeners();
  }

  Future<List<String>> _resolveIngredientLines() async {
    if (meal.ingredients.isNotEmpty) return meal.ingredients;

    final cached = _recipeLookup?.allRecipes
        .where((r) => r.id == meal.recipeId)
        .firstOrNull;
    if (cached != null && cached.ingredients.isNotEmpty) {
      return cached.ingredients;
    }

    final remote = await RecipeService.fetchById(meal.recipeId);
    if (remote != null && remote.ingredients.isNotEmpty) {
      return remote.ingredients;
    }

    return const [];
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
