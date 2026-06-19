// lib/data/providers/recipe_provider.dart

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/core/constants/featured_recipes_constants.dart';
import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/recipe_service.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  RecipeStatus _status = RecipeStatus.initial;
  List<Recipe> _allRecipes = [];
  List<Recipe> _searchResults = [];
  List<Recipe> _suggestedRecipes = []; // recipes phù hợp với user profile
  String? _errorMessage;
  String _searchQuery = '';

  final Map<String, List<Recipe>> _featuredCache = {};
  DateTime Function() _featuredNow = DateTime.now;

  @visibleForTesting
  set featuredNowForTesting(DateTime Function() value) => _featuredNow = value;

  @visibleForTesting
  void setAllRecipesForTesting(List<Recipe> recipes) {
    _allRecipes = List<Recipe>.from(recipes);
    _status = RecipeStatus.loaded;
    _featuredCache.clear();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────
  RecipeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isLoading => _status == RecipeStatus.loading;
  bool get isLoaded => _status == RecipeStatus.loaded;

  List<Recipe> get allRecipes => _allRecipes;
  List<Recipe> get searchResults => _searchResults;
  List<Recipe> get suggestedRecipes => _suggestedRecipes;

  // Phân loại theo meal type
  List<Recipe> get breakfastRecipes =>
      _allRecipes.where((r) => r.mealType == 'breakfast').toList();
  List<Recipe> get lunchRecipes =>
      _allRecipes.where((r) => r.mealType == 'lunch').toList();
  List<Recipe> get dinnerRecipes =>
      _allRecipes.where((r) => r.mealType == 'dinner').toList();
  List<Recipe> get snackRecipes =>
      _allRecipes.where((r) => r.mealType == 'snack').toList();

  UserModel? _user;

  void updateFromUser(UserModel? user) {
    _user = user;
  }

  // ─── Load tất cả recipes khi app start ───────────────────────────────────
  Future<void> loadAll({bool forceReload = false}) async {
    if (_status == RecipeStatus.loaded && !forceReload) return;

    _status = RecipeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final premium = _user?.isPremium ?? false;
      _allRecipes = await RecipeService.fetchAll(
        premiumCatalog: premium,
        limit: PlanLimits.recipeFetchLimit(
          premium ? PlanLimits.tierPremium : PlanLimits.tierFree,
        ),
      );
      _featuredCache.clear();
      _status = RecipeStatus.loaded;
    } catch (e) {
      _errorMessage = 'recipe.err_load_failed';
      _status = RecipeStatus.error;
    }
    notifyListeners();
  }

  // ─── Load recipes phù hợp với user (dùng cho "For You" section) ──────────
  Future<void> loadForUser(UserModel? user) async {
    if (user == null) return;

    // Nếu allRecipes chưa có thì load trước
    if (_allRecipes.isEmpty) await loadAll();

    // Filter local theo goal và calorie target
    final calorieMax = _calorieMaxForGoal(user.goal);
    final minProtein = user.goal == 'build-muscle' ? 20 : 0;

    _suggestedRecipes =
        _allRecipes.where((r) {
            if (r.calories > calorieMax) return false;
            if (r.protein < minProtein) return false;
            return true;
          }).toList()
          // Sort: món khớp goal lên trước
          ..sort(
            (a, b) => _scoreRecipe(
              b,
              user.goal,
            ).compareTo(_scoreRecipe(a, user.goal)),
          );

    notifyListeners();
  }

  int _calorieMaxForGoal(String? goal) {
    switch (goal) {
      case 'lose-weight':
        return 450;
      case 'build-muscle':
        return 650;
      default:
        return 600;
    }
  }

  int _scoreRecipe(Recipe r, String? goal) {
    int score = 0;
    switch (goal) {
      case 'lose-weight':
        if (r.tags.any((t) => t.toLowerCase().contains('low carb'))) score += 2;
        if (r.calories < 350) score += 2;
        break;
      case 'build-muscle':
        if (r.protein >= 30) score += 3;
        if (r.tags.any((t) => t.toLowerCase().contains('high protein')))
          score += 2;
        break;
      case 'maintain':
      case 'health':
        if (r.tags.any(
          (t) =>
              t.toLowerCase().contains('vegan') ||
              t.toLowerCase().contains('fiber'),
        ))
          score += 1;
        break;
    }
    return score;
  }

  /// Home teaser: up to [count] recipes, stable per calendar day + [filterKey].
  /// [filterKey] should be [buildFeaturedFilterKey](mealType, tag).
  List<Recipe> featuredRecipes({
    required String filterKey,
    String mealType = 'all',
    String? tag,
    int count = kFeaturedRecipeCount,
  }) {
    if (_allRecipes.isEmpty) return [];

    final filtered = _recipesForFeatured(mealType: mealType, tag: tag);
    if (filtered.isEmpty) return [];

    final dateKey = _featuredDateKey(_featuredNow());
    final cacheKey = '$dateKey|$filterKey';

    final cached = _featuredCache[cacheKey];
    if (cached != null) return cached;

    final shuffled = List<Recipe>.from(filtered)
      ..shuffle(Random(cacheKey.hashCode));
    final result = shuffled.take(count).toList(growable: false);
    _featuredCache[cacheKey] = result;
    return result;
  }

  List<Recipe> _recipesForFeatured({
    required String mealType,
    String? tag,
  }) {
    final List<Recipe> byType = switch (mealType) {
      'breakfast' => breakfastRecipes,
      'lunch' => lunchRecipes,
      'dinner' => dinnerRecipes,
      'snack' => snackRecipes,
      _ => List<Recipe>.from(_allRecipes),
    };
    if (tag == null) return byType;
    return byType.where((r) => r.tags.contains(tag)).toList(growable: false);
  }

  static String _featuredDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  // ─── Filter nâng cao (dùng cho Search screen) ────────────────────────────
  List<Recipe> filterRecipes({
    String? mealType, // null = all
    int? maxCalories, // null = no limit
    String? difficulty, // null = all
  }) {
    return _allRecipes.where((r) {
      if (mealType != null && r.mealType != mealType) return false;
      if (maxCalories != null && r.calories > maxCalories) return false;
      if (difficulty != null && r.difficulty != difficulty) return false;
      return true;
    }).toList();
  }

  // ─── Tìm kiếm ─────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Search local trước (nhanh hơn, offline-friendly)
    final q = query.toLowerCase();
    _searchResults = _allRecipes.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q)) ||
          (r.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    notifyListeners();

    // Nếu local không có kết quả → query Supabase
    if (_searchResults.isEmpty) {
      try {
        _searchResults = await RecipeService.search(query);
        notifyListeners();
      } catch (_) {
        // Silent fail — local search đã trả về empty, không cần báo lỗi
      }
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // ─── Reload (pull-to-refresh) ─────────────────────────────────────────────
  Future<void> reload() async {
    _status = RecipeStatus.initial;
    await loadAll();
  }
}
