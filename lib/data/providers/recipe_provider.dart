import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:flutter/foundation.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  RecipeStatus _status = RecipeStatus.initial;
  List<Meal> _allRecipes = const [];

  RecipeStatus get status => _status;
  bool get isLoading => _status == RecipeStatus.loading;
  bool get isLoaded => _status == RecipeStatus.loaded;
  List<Meal> get allRecipes => _allRecipes;

  List<Meal> get breakfastRecipes =>
      _allRecipes.where((meal) => meal.type == MealType.breakfast).toList(growable: false);
  List<Meal> get lunchRecipes =>
      _allRecipes.where((meal) => meal.type == MealType.lunch).toList(growable: false);
  List<Meal> get dinnerRecipes =>
      _allRecipes.where((meal) => meal.type == MealType.dinner).toList(growable: false);
  List<Meal> get snackRecipes =>
      _allRecipes.where((meal) => meal.type == MealType.snack).toList(growable: false);

  Future<void> loadAll() async {
    if (isLoading) return;

    _status = RecipeStatus.loading;
    notifyListeners();

    try {
      final weekPlan = MealData.generateWeekPlan();
      _allRecipes = weekPlan
          .expand((day) => day.meals)
          .toList(growable: false);
      _status = RecipeStatus.loaded;
    } catch (_) {
      _allRecipes = const [];
      _status = RecipeStatus.error;
    }

    notifyListeners();
  }

  Future<void> reload() => loadAll();
}
