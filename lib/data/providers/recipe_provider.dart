// lib/data/providers/recipe_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/services/recipe_service.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  RecipeStatus _status = RecipeStatus.initial;
  List<Recipe> _allRecipes = [];
  List<Recipe> _searchResults = [];
  String? _errorMessage;
  String _searchQuery = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  RecipeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isLoading => _status == RecipeStatus.loading;
  bool get isLoaded => _status == RecipeStatus.loaded;

  List<Recipe> get allRecipes => _allRecipes;
  List<Recipe> get searchResults => _searchResults;

  // Phân loại để dùng ở Home (hiển thị featured theo từng bữa)
  List<Recipe> get breakfastRecipes =>
      _allRecipes.where((r) => r.mealType == 'breakfast').toList();
  List<Recipe> get lunchRecipes =>
      _allRecipes.where((r) => r.mealType == 'lunch').toList();
  List<Recipe> get dinnerRecipes =>
      _allRecipes.where((r) => r.mealType == 'dinner').toList();
  List<Recipe> get snackRecipes =>
      _allRecipes.where((r) => r.mealType == 'snack').toList();

  // ─── Load tất cả recipes khi app start ───────────────────────────────────
  Future<void> loadAll() async {
    if (_status == RecipeStatus.loaded) return; // đã load rồi → bỏ qua

    _status = RecipeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRecipes = await RecipeService.fetchAll(limit: 50);
      _status = RecipeStatus.loaded;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách món ăn. Vui lòng thử lại.';
      _status = RecipeStatus.error;
    }
    notifyListeners();
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
