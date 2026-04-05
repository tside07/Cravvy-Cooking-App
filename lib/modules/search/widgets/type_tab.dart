import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/ingredient_input_bar_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_suggestion_tile_widget.dart';

class TypeTab extends StatelessWidget {
  const TypeTab({
    super.key,
    required this.controller,
    required this.addedIngredients,
    required this.commonIngredients,
    required this.suggestedRecipes,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<String> addedIngredients;
  final List<String> commonIngredients;
  final List<(String, String, String, String, int)> suggestedRecipes;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppPad.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IngredientInputBarWidget(controller: controller, onAdd: onAdd),
          AppGap.h16,

          if (addedIngredients.isNotEmpty) ...[
            Text(
              'Added (${addedIngredients.length})',
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: addedIngredients
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      labelStyle: AppTextStyles.s14.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                      backgroundColor: AppColors.primaryLight,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      onDeleted: () => onRemove(item),
                      padding: AppPad.h4, //TODO: use AppPad.h4 (horizontal: 4, no vertical)
                    ),
                  )
                  .toList(),
            ),
            AppGap.h16,
          ],

          Text(
            'Common ingredients',
            style: AppTextStyles.s14.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppGap.h10,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonIngredients.map((item) {
              final clean = item.contains(' ')
                  ? item.substring(item.indexOf(' ') + 1)
                  : item;
              final isAdded = addedIngredients.contains(clean);
              return GestureDetector(
                onTap: () => onAdd(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: AppPad.h12v8,
                  decoration: BoxDecoration(
                    color: isAdded ? AppColors.primaryLight : AppColors.surface,
                    borderRadius: AppBorderRadius.a12,
                    border: Border.all(
                      color: isAdded ? AppColors.primary : AppColors.border,
                      width: isAdded ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: AppTextStyles.s14.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isAdded
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (addedIngredients.isNotEmpty) ...[
            AppGap.h24,
            Row(
              children: [
                Text(
                  'Recipe Suggestions',
                  style: AppTextStyles.s18.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppGap.w8,
                Container(
                  padding: AppPad.h8v4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppBorderRadius.a8,
                  ),
                  child: Text(
                    '${suggestedRecipes.length}',
                    style: AppTextStyles.s12.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h12,
            ...suggestedRecipes.map(
              (r) => RecipeSuggestionTileWidget(recipe: r),
            ),
          ],
          AppGap.h80,
        ],
      ),
    );
  }
}
