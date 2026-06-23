// Profile-aware recipe filtering for meal plans.
// Keep logic in sync with supabase/functions/_shared/profile_recipe_filter.ts

import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';

/// Diets that only affect ranking, not hard exclusion.
const kSoftDiets = {
  'No Specific Diet',
  'Eat Clean',
  'High-Protein',
  'Intermittent Fasting',
};

/// Maps setup labels → tokens searched in name, tags, and ingredients.
const kAvoidTokenMap = <String, List<String>>{
  'Peanuts': ['peanut', 'peanuts', 'đậu phộng', 'lac'],
  'Shellfish': ['shellfish', 'shrimp', 'prawn', 'crab', 'lobster', 'tôm', 'cua'],
  'Dairy': ['dairy', 'milk', 'cheese', 'cream', 'butter', 'yogurt', 'sữa', 'phô mai'],
  'Gluten': ['gluten', 'wheat', 'flour', 'bread', 'mì', 'bánh mì'],
  'Eggs': ['egg', 'eggs', 'trứng'],
  'Soy': ['soy', 'tofu', 'đậu nành', 'tương'],
  'Tree Nuts': ['almond', 'walnut', 'cashew', 'pecan', 'hazelnut', 'hạnh nhân', 'óc chó'],
  'Fish': ['fish', 'salmon', 'tuna', 'cá'],
  'No Pork': ['pork', 'heo', 'thịt heo'],
  'No Beef': ['beef', 'bò', 'thịt bò'],
  'No Seafood': [
    'seafood',
    'fish',
    'shellfish',
    'shrimp',
    'prawn',
    'crab',
    'lobster',
    'tôm',
    'cua',
    'cá',
  ],
  'No Spicy': ['spicy', 'chili', 'chilli', 'pepper', 'cay', 'ớt'],
  'No Raw Foods': ['raw', 'sống', 'sashimi'],
};

const _meatFishTokens = [
  'pork',
  'beef',
  'chicken',
  'meat',
  'fish',
  'seafood',
  'shellfish',
  'shrimp',
  'prawn',
  'crab',
  'lobster',
  'salmon',
  'tuna',
  'thịt',
  'gà',
  'bò',
  'heo',
  'cá',
  'tôm',
  'cua',
];

const _animalProductTokens = [
  ..._meatFishTokens,
  'egg',
  'eggs',
  'dairy',
  'milk',
  'cheese',
  'cream',
  'butter',
  'yogurt',
  'honey',
  'gelatin',
  'trứng',
  'sữa',
  'phô mai',
];

const _glutenTokens = [
  'gluten',
  'wheat',
  'flour',
  'bread',
  'noodle',
  'pasta',
  'mì',
  'bánh mì',
];

const _sugarTokens = [
  'sugar',
  'sweet',
  'dessert',
  'candy',
  'syrup',
  'đường',
  'ngọt',
];

/// Allergy labels (vs. mere preferences) — conflicts with these are dangerous.
const kAllergenLabels = {
  'Peanuts',
  'Shellfish',
  'Dairy',
  'Gluten',
  'Eggs',
  'Soy',
  'Tree Nuts',
  'Fish',
};

/// A clash between a user-entered ingredient and their saved profile.
class IngredientConflict {
  const IngredientConflict({
    required this.ingredient,
    required this.rule,
    required this.isAllergen,
  });

  /// The ingredient the user typed/picked that triggered the conflict.
  final String ingredient;

  /// The profile rule it violates — a diet label ('Vegan') or an avoid label
  /// ('Peanuts', 'No Pork', or a custom entry).
  final String rule;

  /// True when [rule] is a declared allergy (highest-risk).
  final bool isAllergen;
}

class ProfileRecipeFilter {
  ProfileRecipeFilter._();

  /// Detects ingredients the user just entered that clash with their profile
  /// (hard diets + avoid foods/allergens). Pure — safe to unit test.
  static List<IngredientConflict> detectInputConflicts({
    required List<String> ingredients,
    required List<String> diets,
    required List<String> avoidFoods,
  }) {
    final conflicts = <IngredientConflict>[];
    final seen = <String>{};

    void add(String ingredient, String rule, bool isAllergen) {
      if (seen.add('$ingredient|$rule')) {
        conflicts.add(IngredientConflict(
          ingredient: ingredient,
          rule: rule,
          isAllergen: isAllergen,
        ));
      }
    }

    bool matches(String ingLower, List<String> tokens) =>
        tokens.any((t) => ingLower.contains(t) || t.contains(ingLower));

    for (final raw in ingredients) {
      final ing = raw.trim();
      if (ing.isEmpty) continue;
      final ingLower = ing.toLowerCase();

      // Hard dietary rules.
      for (final diet in diets) {
        switch (diet) {
          case 'Vegan':
            if (matches(ingLower, _animalProductTokens)) {
              add(ing, 'Vegan', false);
            }
            break;
          case 'Vegetarian':
            if (matches(ingLower, _meatFishTokens)) {
              add(ing, 'Vegetarian', false);
            }
            break;
          case 'Gluten-Free':
            if (matches(ingLower, _glutenTokens)) {
              add(ing, 'Gluten-Free', false);
            }
            break;
        }
      }

      // Avoid foods / allergens.
      for (final label in avoidFoods) {
        final tokens = expandAvoidTokens(label);
        if (matches(ingLower, tokens)) {
          add(ing, label, kAllergenLabels.contains(label));
        }
      }
    }
    return conflicts;
  }

  static String normalizeDietToken(String value) {
    return value.toLowerCase().replaceAll('-', ' ').trim();
  }

  static List<String> expandAvoidTokens(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const [];
    return kAvoidTokenMap[trimmed] ?? [trimmed.toLowerCase()];
  }

  static String recipeCorpus(Recipe recipe) {
    return [
      recipe.name,
      ...recipe.tags,
      ...recipe.ingredients,
    ].join(' ').toLowerCase();
  }

  static bool corpusContainsAny(String corpus, List<String> tokens) {
    return tokens.any(corpus.contains);
  }

  static bool violatesAvoidFoods(Recipe recipe, List<String> avoidFoods) {
    if (avoidFoods.isEmpty) return false;
    final corpus = recipeCorpus(recipe);
    for (final item in avoidFoods) {
      final tokens = expandAvoidTokens(item);
      if (corpusContainsAny(corpus, tokens)) return true;
    }
    return false;
  }

  static bool passesDietHardFilters(Recipe recipe, List<String> diets) {
    if (diets.isEmpty || diets.contains('No Specific Diet')) return true;

    final active = diets.where((d) => !kSoftDiets.contains(d)).toList();
    if (active.isEmpty) return true;

    for (final diet in active) {
      if (!_passesSingleDiet(recipe, diet)) return false;
    }
    return true;
  }

  static bool _passesSingleDiet(Recipe recipe, String diet) {
    final corpus = recipeCorpus(recipe);
    final normalizedTags = recipe.tags.map(normalizeDietToken).toList();

    switch (diet) {
      case 'Vegan':
        return !corpusContainsAny(corpus, _animalProductTokens);
      case 'Vegetarian':
        return !corpusContainsAny(corpus, _meatFishTokens);
      case 'Gluten-Free':
        if (normalizedTags.any((t) => t.contains('gluten free'))) return true;
        return !corpusContainsAny(corpus, _glutenTokens);
      case 'Keto':
        if (normalizedTags.any((t) => t.contains('keto'))) return true;
        return recipe.carbs <= 25;
      case 'Low-Carb':
        if (normalizedTags.any((t) => t.contains('low carb'))) return true;
        return recipe.carbs <= 45;
      case 'Low-Sugar':
        if (normalizedTags.any((t) => t.contains('low sugar'))) return true;
        return !corpusContainsAny(corpus, _sugarTokens);
      default:
        return true;
    }
  }

  static bool matchesProfile(Recipe recipe, UserModel user) {
    if (violatesAvoidFoods(recipe, user.avoidFoods)) return false;
    if (!passesDietHardFilters(recipe, user.diets)) return false;
    return true;
  }

  static List<Recipe> filterRecipes(List<Recipe> recipes, UserModel user) {
    return recipes.where((r) => matchesProfile(r, user)).toList();
  }

  static bool tagMatchesDiet(String tag, String diet) {
    final normalizedTag = normalizeDietToken(tag);
    final normalizedDiet = normalizeDietToken(diet);
    return normalizedTag.contains(normalizedDiet) ||
        normalizedDiet.contains(normalizedTag);
  }

  static int scoreRecipe(Recipe recipe, UserModel user) {
    int score = 0;
    switch (user.goal) {
      case 'lose-weight':
        if (recipe.calories < 350) score += 3;
        if (recipe.calories < 450) score += 1;
        if (recipe.tags.any(
          (t) => normalizeDietToken(t).contains('low carb'),
        )) {
          score += 2;
        }
        break;
      case 'build-muscle':
        if (recipe.protein >= 30) score += 4;
        if (recipe.protein >= 20) score += 2;
        if (recipe.tags.any(
          (t) => normalizeDietToken(t).contains('high protein'),
        )) {
          score += 2;
        }
        break;
      default:
        if (recipe.calories < 600) score += 1;
    }

    for (final diet in user.diets) {
      if (kSoftDiets.contains(diet)) continue;
      if (recipe.tags.any((t) => tagMatchesDiet(t, diet))) {
        score += 3;
      }
    }
    return score;
  }
}
