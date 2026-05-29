import 'package:cravvy_cooking_app/core/constants/featured_recipes_constants.dart';
import 'package:cravvy_cooking_app/core/utils/featured_recipes_utils.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _recipe(
  int index, {
  String mealType = 'lunch',
  List<String> tags = const [],
}) {
  return Recipe(
    id: 'recipe-$index',
    name: 'Recipe $index',
    calories: 300,
    protein: 20,
    carbs: 30,
    fat: 10,
    prepTime: 20,
    difficulty: 'easy',
    mealType: mealType,
    tags: tags,
  );
}

List<Recipe> _lunchPool(int count) =>
    List.generate(count, (i) => _recipe(i, mealType: 'lunch'));

void main() {
  group('buildFeaturedFilterKey', () {
    test('joins meal type and tag', () {
      expect(buildFeaturedFilterKey('all', null), 'all|');
      expect(buildFeaturedFilterKey('breakfast', 'Vegan'), 'breakfast|Vegan');
    });
  });

  group('RecipeProvider.featuredRecipes', () {
    late RecipeProvider provider;

    setUp(() {
      provider = RecipeProvider();
      provider.featuredNowForTesting = () => DateTime(2026, 5, 29);
      provider.setAllRecipesForTesting(_lunchPool(50));
    });

    test('returns at most kFeaturedRecipeCount items', () {
      final result = provider.featuredRecipes(
        filterKey: buildFeaturedFilterKey('all', null),
        mealType: 'all',
      );
      expect(result.length, kFeaturedRecipeCount);
    });

    test('same day and filterKey yields stable order', () {
      const key = 'all|';
      final first = provider.featuredRecipes(
        filterKey: key,
        mealType: 'all',
      );
      final second = provider.featuredRecipes(
        filterKey: key,
        mealType: 'all',
      );
      expect(second.map((r) => r.id), first.map((r) => r.id));
    });

    test('different filterKey yields different selection when pool is large', () {
      final pool = <Recipe>[
        ...List.generate(
          25,
          (i) => _recipe(i, mealType: 'breakfast'),
        ),
        ...List.generate(
          25,
          (i) => _recipe(i + 25, mealType: 'lunch'),
        ),
      ];
      provider.setAllRecipesForTesting(pool);

      final allKey = buildFeaturedFilterKey('all', null);
      final lunchKey = buildFeaturedFilterKey('lunch', null);

      final allFeatured = provider.featuredRecipes(
        filterKey: allKey,
        mealType: 'all',
      );
      final lunchFeatured = provider.featuredRecipes(
        filterKey: lunchKey,
        mealType: 'lunch',
      );

      expect(
        allFeatured.map((r) => r.id).toSet(),
        isNot(equals(lunchFeatured.map((r) => r.id).toSet())),
      );
      for (final r in lunchFeatured) {
        expect(r.mealType, 'lunch');
      }
    });

    test('different calendar day uses new cache entry', () {
      const key = 'all|';
      final dayOne = provider.featuredRecipes(
        filterKey: key,
        mealType: 'all',
      );
      provider.featuredNowForTesting = () => DateTime(2026, 5, 30);
      final dayTwo = provider.featuredRecipes(
        filterKey: key,
        mealType: 'all',
      );
      expect(
        dayTwo.map((r) => r.id).join(','),
        isNot(equals(dayOne.map((r) => r.id).join(','))),
      );
    });

    test('filters by quick tag before sampling', () {
      final pool = [
        _recipe(0, tags: ['Vegan']),
        _recipe(1, tags: ['Vegan']),
        _recipe(2),
        _recipe(3),
      ];
      provider.setAllRecipesForTesting(pool);

      final result = provider.featuredRecipes(
        filterKey: buildFeaturedFilterKey('all', 'Vegan'),
        mealType: 'all',
        tag: 'Vegan',
      );
      expect(result.length, 2);
      expect(result.every((r) => r.tags.contains('Vegan')), isTrue);
    });

    test('returns all items when filtered pool is smaller than count', () {
      provider.setAllRecipesForTesting(_lunchPool(5));
      final result = provider.featuredRecipes(
        filterKey: buildFeaturedFilterKey('all', null),
        mealType: 'all',
      );
      expect(result.length, 5);
    });

    test('returns empty list when catalog is empty', () {
      provider.setAllRecipesForTesting([]);
      final result = provider.featuredRecipes(
        filterKey: buildFeaturedFilterKey('all', null),
        mealType: 'all',
      );
      expect(result, isEmpty);
    });

    test('setAllRecipesForTesting clears featured cache', () {
      const key = 'all|';
      provider.featuredRecipes(filterKey: key, mealType: 'all');

      provider.setAllRecipesForTesting(
        List.generate(50, (i) => _recipe(1000 + i)),
      );

      final afterReload = provider.featuredRecipes(
        filterKey: key,
        mealType: 'all',
      );
      final oldIds = List.generate(50, (i) => 'recipe-$i').toSet();
      expect(
        afterReload.map((r) => r.id).any(oldIds.contains),
        isFalse,
      );
    });
  });
}
