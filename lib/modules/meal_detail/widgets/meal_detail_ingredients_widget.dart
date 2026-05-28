import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_ingredient_item_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

/// Full ingredient list + "Add missing to shopping list" button.
class MealDetailIngredientsWidget extends StatelessWidget {
  const MealDetailIngredientsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealDetailProvider>(
      builder: (context, provider, _) {
        final ingredients = provider.ingredients;
        final missingCount = provider.missingIngredients.length;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Last item → "Add missing" button
              if (index == ingredients.length) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 100,
                  ),
                  child: CravvyButton(
                    label: missingCount > 0
                        ? 'meal_detail.add_missing'.tr(
                            namedArgs: {'n': '$missingCount'},
                          )
                        : 'meal_detail.all_available'.tr(),
                    icon: Icons.shopping_cart_outlined,
                    backgroundColor: missingCount > 0
                        ? AppColors.primary
                        : AppColors.success,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            missingCount > 0
                                ? 'meal_detail.snack_added'.tr(
                                    namedArgs: {'n': '$missingCount'},
                                  )
                                : 'meal_detail.snack_have_all'.tr(),
                          ),
                          backgroundColor: missingCount > 0
                              ? AppColors.primary
                              : AppColors.success,
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
                    const Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 16,
                      color: AppColors.border,
                    ),
                ],
              );
            },
            childCount: ingredients.length + 1, // +1 for the button
          ),
        );
      },
    );
  }
}
