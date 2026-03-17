import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'ingredient_input_bar.dart';
import 'recipe_suggestion_tile.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IngredientInputBar(controller: controller, onAdd: onAdd),
          const SizedBox(height: 16),

          // Added chips
          if (addedIngredients.isNotEmpty) ...[
            Text(
              'Added (${addedIngredients.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: addedIngredients
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      labelStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                      backgroundColor: AppColors.primaryLight,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1),
                      deleteIcon: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.primary),
                      onDeleted: () => onRemove(item),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Common ingredients
          Text(
            'Common ingredients',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAdded
                        ? AppColors.primaryLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAdded ? AppColors.primary : AppColors.border,
                      width: isAdded ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'Nunito',
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

          // Recipe suggestions
          if (addedIngredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recipe Suggestions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${suggestedRecipes.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestedRecipes.map(
              (r) => RecipeSuggestionTile(recipe: r),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
