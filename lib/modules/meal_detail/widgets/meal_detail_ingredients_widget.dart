import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_ingredient_item_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

/// Full ingredient list + add-to-shopping-list button.
class MealDetailIngredientsWidget extends StatelessWidget {
  const MealDetailIngredientsWidget({super.key, required this.mealName});

  final String mealName;

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final colors = context.appColors;

    return Consumer<MealDetailProvider>(
      builder: (context, provider, _) {
        if (provider.loadingIngredients) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final ingredients = provider.ingredients;
        if (ingredients.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Text(
                'meal_detail.no_ingredients'.tr(),
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final toShop = provider.ingredientsToShop;
        final toShopCount = toShop.length;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == ingredients.length) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 100,
                  ),
                  child: CravvyButton(
                    label: toShopCount > 0
                        ? 'meal_detail.add_missing'.tr(
                            namedArgs: {'n': '$toShopCount'},
                          )
                        : 'meal_detail.all_available'.tr(),
                    icon: Icons.shopping_cart_outlined,
                    backgroundColor: toShopCount > 0
                        ? AppColors.primary
                        : AppColors.success,
                    onTap: toShopCount == 0
                        ? null
                        : () {
                            final meal = context.read<MealDetailProvider>().meal;
                            final added = context
                                .read<ShoppingListProvider>()
                                .addFromMeal(
                                  recipeId: meal.recipeId,
                                  recipeName: mealName,
                                  ingredients: toShop,
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  added > 0
                                      ? 'meal_detail.snack_added'.tr(
                                          namedArgs: {'n': '$added'},
                                        )
                                      : 'meal_detail.snack_already_added'.tr(),
                                ),
                                backgroundColor: added > 0
                                    ? AppColors.primary
                                    : colors.textSecondary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.a12,
                                ),
                              ),
                            );
                          },
                  ),
                );
              }

              return Column(
                children: [
                  MealDetailIngredientItemWidget(
                    ingredient: ingredients[index],
                    index: index,
                  ),
                  if (index < ingredients.length - 1)
                    Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 16,
                      color: colors.borderDivider,
                    ),
                ],
              );
            },
            childCount: ingredients.length + 1,
          ),
        );
      },
    );
  }
}
