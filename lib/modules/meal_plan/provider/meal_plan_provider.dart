import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/meal_plan_service.dart';
import 'package:cravvy_cooking_app/data/services/recipe_service.dart';
import 'package:cravvy_cooking_app/core/utils/nutrition_calculator.dart';
import 'package:cravvy_cooking_app/core/utils/meal_suggester.dart';

enum MealPlanStatus { initial, loading, loaded, error }

class MealPlanProvider extends ChangeNotifier {
  MealPlanStatus _status = MealPlanStatus.initial;
  List<DayPlan> _weekPlan = [];
  int _selectedDayIndex = _todayIndex();
  NutritionTarget _target = NutritionTarget.defaultTarget;
  String? _userId;
  UserModel? _user;

  // key: '${dateStr}_${mealType}' → entryId (Supabase row id)
  final Map<String, String> _entryIdCache = {};

  // ─── Getters ─────────────────────────────────────────────────────────────
  MealPlanStatus get status => _status;
  bool get isLoading => _status == MealPlanStatus.loading;
  bool get isLoaded => _status == MealPlanStatus.loaded;
  List<DayPlan> get weekPlan => _weekPlan;
  int get selectedDayIndex => _selectedDayIndex;
  DayPlan get selectedDay =>
      _weekPlan.isNotEmpty ? _weekPlan[_selectedDayIndex] : _emptyDay();

  int get targetCalories => _target.calories;
  int get targetProtein => _target.protein;
  int get targetCarbs => _target.carbs;
  int get targetFat => _target.fat;

  double get calorieProgress =>
      (selectedDay.totalCalories / _target.calories).clamp(0.0, 1.0);
  double get proteinProgress =>
      (selectedDay.totalProtein / _target.protein).clamp(0.0, 1.0);
  double get carbsProgress =>
      (selectedDay.totalCarbs / _target.carbs).clamp(0.0, 1.0);
  double get fatProgress =>
      (selectedDay.totalFat / _target.fat).clamp(0.0, 1.0);
  int get remainingCalories => _target.calories - selectedDay.totalCalories;

  // ─── Called by AuthProvider ───────────────────────────────────────────────
  void updateFromUser(UserModel? user) {
    if (user == null) {
      _target = NutritionTarget.defaultTarget;
      _userId = null;
      _user = null;
      _weekPlan = [];
      _entryIdCache.clear();
      _status = MealPlanStatus.initial;
      // Dùng Future.microtask để tránh gọi notifyListeners trong build phase
      Future.microtask(notifyListeners);
      return;
    }

    _target = NutritionCalculator.calculate(
      age: user.age,
      gender: user.gender,
      weightKg: user.weightKg,
      heightCm: user.heightCm,
      goal: user.goal,
    );

    _user = user;

    if (_userId != user.id || _status == MealPlanStatus.initial) {
      _userId = user.id;
      // loadWeek tự gọi notifyListeners bên trong — cũng cần defer
      Future.microtask(loadWeek);
    } else {
      // target đổi nhưng userId không đổi
      Future.microtask(notifyListeners);
    }
  }

  static const _mainMealSlots = ['breakfast', 'lunch', 'dinner', 'snack'];

  // ─── Load tuần ───────────────────────────────────────────────────────────
  Future<void> loadWeek({bool suggestIfEmpty = true}) async {
    if (_userId == null) return;
    _status = MealPlanStatus.loading;
    notifyListeners();
    try {
      final weekStart = _currentWeekStart();
      final entries = await MealPlanService.fetchWeek(
        userId: _userId!,
        weekStart: weekStart,
      );
      final recipeIds = entries.map((e) => e.recipeId).toSet().toList();
      final recipes = await _fetchRecipesByIds(recipeIds);
      _weekPlan = _buildWeekPlan(weekStart, entries, recipes);
      _rebuildEntryCache(entries);

      if (suggestIfEmpty && _user != null) {
        if (entries.isEmpty) {
          await autoFillWeek();
          return;
        }
        if (_dayMissingSlots(_selectedDayIndex)) {
          await fillMissingMealsForDay(_weekPlan[_selectedDayIndex].date);
          await loadWeek(suggestIfEmpty: false);
          return;
        }
      }

      _status = MealPlanStatus.loaded;
    } catch (_) {
      if (suggestIfEmpty && _user != null) {
        _applyLocalWeekFromSuggester();
        _status = MealPlanStatus.loaded;
      } else {
        _status = MealPlanStatus.error;
      }
    }
    notifyListeners();
  }

  // ─── Add ─────────────────────────────────────────────────────────────────
  Future<void> addMeal({
    required DateTime date,
    required String mealType,
    required Recipe recipe,
  }) async {
    if (_userId == null) return;
    // Optimistic
    _upsertMealInPlan(date, mealType, _mealFromRecipe(recipe, null));
    notifyListeners();
    try {
      final entry = await MealPlanService.addMeal(
        userId: _userId!,
        date: date,
        mealType: mealType,
        recipeId: recipe.id,
      );
      if (entry != null) {
        _entryIdCache[_cacheKey(date, mealType)] = entry.id;
        _upsertMealInPlan(date, mealType, _mealFromRecipe(recipe, entry.id));
        notifyListeners();
      }
    } catch (_) {
      await loadWeek();
    }
  }

  // ─── Remove ──────────────────────────────────────────────────────────────
  Future<void> removeMeal({
    required DateTime date,
    required String mealType,
  }) async {
    if (_userId == null) return;
    _removeMealFromPlan(date, mealType);
    notifyListeners();
    try {
      await MealPlanService.removeMeal(
        userId: _userId!,
        date: date,
        mealType: mealType,
      );
      _entryIdCache.remove(_cacheKey(date, mealType));
    } catch (_) {
      await loadWeek();
    }
  }

  // ─── Toggle logged ────────────────────────────────────────────────────────
  Future<void> toggleMealLogged(String mealId) async {
    for (var i = 0; i < _weekPlan.length; i++) {
      final idx = _weekPlan[i].meals.indexWhere((m) => m.id == mealId);
      if (idx == -1) continue;
      final meal = _weekPlan[i].meals[idx];
      final newLogged = !meal.isLogged;
      _weekPlan[i] = _weekPlan[i].copyWith(
        meals: _weekPlan[i].meals
            .map((m) => m.id == mealId ? m.copyWith(isLogged: newLogged) : m)
            .toList(),
      );
      notifyListeners();
      final key = _cacheKey(_weekPlan[i].date, _typeStr(meal.type));
      final entryId = _entryIdCache[key];
      if (entryId != null) {
        try {
          await MealPlanService.toggleLogged(
            entryId: entryId,
            isLogged: newLogged,
          );
        } catch (_) {
          await loadWeek();
        }
      }
      return;
    }
  }

  // ─── Swap ─────────────────────────────────────────────────────────────────
  Future<void> swapMeal(String oldMealId, Meal newMeal) async {
    for (var i = 0; i < _weekPlan.length; i++) {
      final idx = _weekPlan[i].meals.indexWhere((m) => m.id == oldMealId);
      if (idx == -1) continue;
      final oldMeal = _weekPlan[i].meals[idx];
      final date = _weekPlan[i].date;
      final mealType = _typeStr(oldMeal.type);
      _weekPlan[i] = _weekPlan[i].copyWith(
        meals: _weekPlan[i].meals
            .map((m) => m.id == oldMealId ? newMeal : m)
            .toList(),
      );
      notifyListeners();
      final entryId = _entryIdCache[_cacheKey(date, mealType)];
      if (entryId != null) {
        try {
          await MealPlanService.swapMeal(
            entryId: entryId,
            newRecipeId: newMeal.id,
          );
        } catch (_) {
          await loadWeek();
        }
      }
      return;
    }
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
    if (_user != null &&
        _weekPlan.isNotEmpty &&
        _dayMissingSlots(index) &&
        _status == MealPlanStatus.loaded) {
      Future.microtask(() async {
        await fillMissingMealsForDay(_weekPlan[index].date);
        await loadWeek(suggestIfEmpty: false);
      });
    }
  }

  Future<void> reload() async {
    _status = MealPlanStatus.initial;
    await loadWeek();
  }

  /// Gợi ý lại toàn bộ tuần theo profile user (MealSuggester → Supabase upsert).
  Future<void> autoFillWeek() async {
    if (_user == null) return;
    _status = MealPlanStatus.loading;
    notifyListeners();
    try {
      final weekStart = _currentWeekStart();
      final weekNumber = weekStart.weekOfYear;
      final byType = await _recipesByMealType();

      if (_userId != null) {
        for (var i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));
          final suggestions = MealSuggester.suggestDay(
            byType: byType,
            user: _user!,
            weekNumber: weekNumber,
            dayOffset: i,
          );
          for (final e in suggestions.entries) {
            await MealPlanService.addMeal(
              userId: _userId!,
              date: date,
              mealType: e.key,
              recipeId: e.value.id,
            );
          }
        }
        await loadWeek(suggestIfEmpty: false);
        return;
      }

      _applyLocalWeekFromSuggester(byType: byType);
      _status = MealPlanStatus.loaded;
    } catch (_) {
      _applyLocalWeekFromSuggester();
      _status = MealPlanStatus.loaded;
    }
    notifyListeners();
  }

  /// Điền các slot còn thiếu (breakfast/lunch/dinner/snack) cho một ngày.
  Future<void> fillMissingMealsForDay(DateTime date) async {
    if (_user == null) return;
    final missing = _missingSlotsForDay(date);
    if (missing.isEmpty) return;

    final byType = await _recipesByMealType();
    final weekStart = _currentWeekStart();
    final dayOffset = date.difference(weekStart).inDays.clamp(0, 6);
    final suggestions = MealSuggester.suggestDay(
      byType: byType,
      user: _user!,
      weekNumber: weekStart.weekOfYear,
      dayOffset: dayOffset,
    );

    for (final mealType in missing) {
      final recipe = suggestions[mealType];
      if (recipe == null) continue;
      if (_userId != null) {
        try {
          await MealPlanService.addMeal(
            userId: _userId!,
            date: date,
            mealType: mealType,
            recipeId: recipe.id,
          );
        } catch (_) {
          _upsertMealInPlan(date, mealType, _mealFromRecipe(recipe, null));
        }
      } else {
        _upsertMealInPlan(date, mealType, _mealFromRecipe(recipe, null));
      }
    }
    notifyListeners();
  }

  // ─── Private ──────────────────────────────────────────────────────────────
  bool _dayMissingSlots(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _weekPlan.length) return false;
    return _missingSlotsForDay(_weekPlan[dayIndex].date).isNotEmpty;
  }

  List<String> _missingSlotsForDay(DateTime date) {
    final i = _dayIndex(date);
    if (i == -1) return List.from(_mainMealSlots);
    final existing = _weekPlan[i].meals.map((m) => _typeStr(m.type)).toSet();
    return _mainMealSlots.where((s) => !existing.contains(s)).toList();
  }

  Future<Map<String, List<Recipe>>> _recipesByMealType() async {
    final recipes = await RecipeService.fetchAll(limit: 100);
    return {
      for (final t in _mainMealSlots)
        t: recipes.where((r) => r.mealType == t).toList(),
    };
  }

  void _applyLocalWeekFromSuggester({Map<String, List<Recipe>>? byType}) {
    if (_user == null) return;
    final weekStart = _currentWeekStart();
    final types = byType ?? {};
    final weekNumber = weekStart.weekOfYear;

    _weekPlan = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      final suggestions = MealSuggester.suggestDay(
        byType: types,
        user: _user!,
        weekNumber: weekNumber,
        dayOffset: i,
      );
      final meals = suggestions.entries
          .map((e) => _mealFromRecipe(e.value, null))
          .toList()
        ..sort((a, b) => a.type.index.compareTo(b.type.index));
      return DayPlan(date: date, meals: meals);
    });
  }

  static int _todayIndex() => DateTime.now().weekday - 1;

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
  }

  Future<Map<String, Recipe>> _fetchRecipesByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final results = await Future.wait(ids.map(RecipeService.fetchById));
    return {
      for (var i = 0; i < ids.length; i++)
        if (results[i] != null) ids[i]: results[i]!,
    };
  }

  List<DayPlan> _buildWeekPlan(
    DateTime weekStart,
    List<MealPlanEntry> entries,
    Map<String, Recipe> recipes,
  ) {
    return List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = MealPlanService.dateStr(date);
      final meals =
          entries
              .where((e) => MealPlanService.dateStr(e.date) == dateStr)
              .expand((e) {
                final r = recipes[e.recipeId];
                if (r == null) return <Meal>[];
                return [_mealFromRecipe(r, e.id, isLogged: e.isLogged)];
              })
              .toList()
            ..sort((a, b) => a.type.index.compareTo(b.type.index));
      return DayPlan(date: date, meals: meals);
    });
  }

  void _rebuildEntryCache(List<MealPlanEntry> entries) {
    _entryIdCache.clear();
    for (final e in entries) {
      _entryIdCache[_cacheKey(e.date, e.mealType)] = e.id;
    }
  }

  void _upsertMealInPlan(DateTime date, String mealType, Meal meal) {
    final i = _dayIndex(date);
    if (i == -1) return;
    final type = _parseType(mealType);
    final meals = _weekPlan[i].meals.where((m) => m.type != type).toList()
      ..add(meal)
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
    _weekPlan[i] = _weekPlan[i].copyWith(meals: meals);
  }

  void _removeMealFromPlan(DateTime date, String mealType) {
    final i = _dayIndex(date);
    if (i == -1) return;
    final type = _parseType(mealType);
    final meals = _weekPlan[i].meals.where((m) => m.type != type).toList();
    _weekPlan[i] = _weekPlan[i].copyWith(meals: meals);
  }

  int _dayIndex(DateTime date) {
    for (var i = 0; i < _weekPlan.length; i++) {
      final d = _weekPlan[i].date;
      if (d.year == date.year && d.month == date.month && d.day == date.day) {
        return i;
      }
    }
    return -1;
  }

  String _cacheKey(DateTime date, String mealType) =>
      '${MealPlanService.dateStr(date)}_$mealType';

  String _typeStr(MealType t) {
    switch (t) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
      case MealType.snack:
        return 'snack';
    }
  }

  MealType _parseType(String raw) {
    switch (raw) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.snack;
    }
  }

  Meal _mealFromRecipe(Recipe r, String? entryId, {bool isLogged = false}) =>
      Meal(
        id: entryId ?? r.id,
        name: r.name,
        type: _parseType(r.mealType),
        calories: r.calories,
        protein: r.protein,
        carbs: r.carbs,
        fat: r.fat,
        prepTime: r.prepTime,
        imageUrl: r.imageUrl ?? '',
        isLogged: isLogged,
        tags: r.tags,
        steps: r.steps,
      );

  DayPlan _emptyDay() => DayPlan(date: DateTime.now(), meals: const []);
}
