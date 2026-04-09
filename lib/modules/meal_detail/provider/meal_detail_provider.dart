import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';

/// Which tab is active on the detail screen.
enum MealDetailTab { ingredients, nutrition, instructions }

class MealDetailProvider extends ChangeNotifier {
  MealDetailProvider(this.meal)
      : _ingredients = _mockIngredients(meal.id),
        _checkedIds = {};

  final Meal meal;

  // ── Tab state ─────────────────────────────────────────────────────────────
  MealDetailTab _activeTab = MealDetailTab.ingredients;
  MealDetailTab get activeTab => _activeTab;

  void selectTab(MealDetailTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  // ── Servings ──────────────────────────────────────────────────────────────
  int _servings = 2;
  int get servings => _servings;

  void incrementServings() {
    _servings++;
    notifyListeners();
  }

  void decrementServings() {
    if (_servings <= 1) return;
    _servings--;
    notifyListeners();
  }

  // ── Ingredients ───────────────────────────────────────────────────────────
  final List<MealDetailIngredient> _ingredients;
  List<MealDetailIngredient> get ingredients => _ingredients;

  List<MealDetailIngredient> get missingIngredients =>
      _ingredients.where((i) => i.status == IngredientStatus.missing).toList();

  // ── Checkbox state ────────────────────────────────────────────────────────
  final Set<int> _checkedIds;

  bool isChecked(int index) => _checkedIds.contains(index);

  void toggleChecked(int index) {
    if (_checkedIds.contains(index)) {
      _checkedIds.remove(index);
    } else {
      _checkedIds.add(index);
    }
    notifyListeners();
  }

  // ── Mock data ─────────────────────────────────────────────────────────────
  static List<MealDetailIngredient> _mockIngredients(String mealId) {
    const base = [
      MealDetailIngredient(
        name: 'fresh salmon fillet',
        quantity: '400g',
        status: IngredientStatus.available,
      ),
      MealDetailIngredient(
        name: 'broccoli florets',
        quantity: '2 cups',
        status: IngredientStatus.available,
      ),
      MealDetailIngredient(
        name: 'cherry tomatoes',
        quantity: '1 cup',
        status: IngredientStatus.available,
      ),
      MealDetailIngredient(
        name: 'olive oil',
        quantity: '2 tbsp',
        status: IngredientStatus.available,
      ),
      MealDetailIngredient(
        name: 'garlic, minced',
        quantity: '2 cloves',
        status: IngredientStatus.missing,
      ),
      MealDetailIngredient(
        name: 'lemon, sliced',
        quantity: '1',
        status: IngredientStatus.missing,
      ),
      MealDetailIngredient(
        name: 'Salt and pepper',
        quantity: 'to taste',
        status: IngredientStatus.available,
      ),
      MealDetailIngredient(
        name: 'Fresh herbs (dill or parsley)',
        quantity: 'handful',
        status: IngredientStatus.missing,
      ),
    ];

    // Return some variations per meal so different dishes look different.
    switch (mealId) {
      case 'b1': // Avocado Toast Bowl
        return const [
          MealDetailIngredient(
            name: 'sourdough bread',
            quantity: '2 slices',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'ripe avocado',
            quantity: '1 large',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'cherry tomatoes, halved',
            quantity: '½ cup',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'poached eggs',
            quantity: '2',
            status: IngredientStatus.missing,
          ),
          MealDetailIngredient(
            name: 'red pepper flakes',
            quantity: '½ tsp',
            status: IngredientStatus.missing,
          ),
          MealDetailIngredient(
            name: 'lemon juice',
            quantity: '1 tbsp',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'Salt and pepper',
            quantity: 'to taste',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'microgreens',
            quantity: 'handful',
            status: IngredientStatus.missing,
          ),
        ];

      case 'l1': // Grilled Chicken Salad
        return const [
          MealDetailIngredient(
            name: 'chicken breast',
            quantity: '200g',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'mixed salad greens',
            quantity: '3 cups',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'cucumber, sliced',
            quantity: '1',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'red onion, thinly sliced',
            quantity: '¼',
            status: IngredientStatus.missing,
          ),
          MealDetailIngredient(
            name: 'feta cheese',
            quantity: '50g',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'olive oil',
            quantity: '2 tbsp',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'lemon juice',
            quantity: '1 tbsp',
            status: IngredientStatus.available,
          ),
          MealDetailIngredient(
            name: 'Dijon mustard',
            quantity: '1 tsp',
            status: IngredientStatus.missing,
          ),
        ];

      default:
        return base;
    }
  }
}
