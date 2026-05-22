import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/alternative_tile_widget.dart';

class MealSwapSheet extends StatelessWidget {
  const MealSwapSheet({super.key, required this.meal});

  final Meal meal;

  /// Convert Recipe → Meal để dùng với AlternativeTileWidget và swapMeal().
  /// QUAN TRỌNG: meal.id phải là recipe.id (UUID thật từ Supabase),
  /// không phải entry id — MealPlanProvider.swapMeal() dùng newMeal.id
  /// làm newRecipeId khi gọi MealPlanService.swapMeal().
  Meal _recipeToMeal(Recipe recipe) => Meal(
    id: recipe.id, // UUID thật — an toàn để persist vào Supabase
    name: recipe.name,
    type: meal.type,
    calories: recipe.calories,
    protein: recipe.protein,
    carbs: recipe.carbs,
    fat: recipe.fat,
    prepTime: recipe.prepTime,
    imageUrl: recipe.imageUrl ?? '',
    tags: recipe.tags,
    steps: recipe.steps,
  );

  @override
  Widget build(BuildContext context) {
    // RecipeProvider đã loaded từ app start — không cần async ở đây
    final recipeProvider = context.watch<RecipeProvider>();

    // Filter theo mealType của slot hiện tại, loại bỏ chính món đang swap
    // (so sánh theo name vì meal.id là entryId, không phải recipeId)
    final mealTypeName = _mealTypeToString(meal.type);
    final alternatives = recipeProvider.allRecipes
        .where(
          (r) => r.mealType == mealTypeName && r.name != meal.name,
        ) // tránh suggest lại chính món đó
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: AppPad.t12,
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppBorderRadius.a2,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swap Meal',
                        style: AppTextStyles.s18.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Choose a replacement for ${meal.name}',
                        style: AppTextStyles.s14.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Info banner — món đang được thay
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: AppPad.a12,
            decoration: BoxDecoration(
              color: meal.type.lightColor,
              borderRadius: AppBorderRadius.a16,
              border: Border.all(color: meal.type.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: meal.type.color,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Replacing: ${meal.name}',
                    style: AppTextStyles.s14.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: meal.type.color,
                    ),
                  ),
                ),
                Text(
                  '${meal.calories} kcal',
                  style: AppTextStyles.s12.copyWith(color: meal.type.color),
                ),
              ],
            ),
          ),

          AppGap.h16,

          // List alternatives
          Expanded(
            child: alternatives.isEmpty
                ? _EmptyAlternatives(mealType: meal.type)
                : ListView.builder(
                    padding: AppPad.h16,
                    itemCount: alternatives.length,
                    itemBuilder: (context, i) {
                      final newMeal = _recipeToMeal(alternatives[i]);
                      return AlternativeTileWidget(
                        meal: newMeal,
                        originalCalories: meal.calories,
                        onSelect: () {
                          context.read<MealPlanProvider>().swapMeal(
                            meal.id,
                            newMeal,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Swapped to ${newMeal.name}',
                                style: AppTextStyles.s14.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppBorderRadius.a12,
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _mealTypeToString(MealType type) {
    switch (type) {
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
}

/// Fallback khi RecipeProvider chưa loaded hoặc không có món nào cùng type
class _EmptyAlternatives extends StatelessWidget {
  const _EmptyAlternatives({required this.mealType});

  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mealType.emoji, style: const TextStyle(fontSize: 40)),
          AppGap.h12,
          Text(
            'No alternatives available',
            style: AppTextStyles.s16.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppGap.h6,
          Text(
            'Try adding more recipes to your plan',
            style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
