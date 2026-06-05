import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_search_result_tile.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_suggestion_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

class TypeTab extends StatelessWidget {
  const TypeTab({
    super.key,
    required this.searchCtrl,
    required this.ingredientCtrl,
    required this.addedIngredients,
    required this.commonIngredients,
    required this.onAdd,
    required this.onRemove,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.hasActiveFilter,
    this.filterMealType,
    this.filterMaxCalories,
    this.filterDifficulty,
  });

  final TextEditingController searchCtrl;
  final TextEditingController ingredientCtrl;
  final List<String> addedIngredients;
  final List<String> commonIngredients;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;
  final String? filterMealType;
  final int? filterMaxCalories;
  final String? filterDifficulty;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: AppPad.h16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search bar + Filter button ──────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.inputFieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: appColors.inputBorder),
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: onSearchChanged,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: appColors.textPrimary,
                            ),
                        decoration: InputDecoration(
                          hintText: 'search.search_recipes'.tr(),
                          hintStyle: AppTextStyles.s14.copyWith(
                            color: appColors.inputHint,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: appColors.inputHint,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasActiveFilter
                            ? AppColors.primary
                            : appColors.inputFieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasActiveFilter
                              ? AppColors.primary
                              : appColors.inputBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: hasActiveFilter
                            ? appColors.onPrimary
                            : appColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Active filter chips ─────────────────────────────────────
              if (hasActiveFilter) ...[
                AppGap.h8,
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (filterMealType != null)
                      FilterChipWidget(label: filterMealType!),
                    if (filterMaxCalories != null)
                      FilterChipWidget(label: '< $filterMaxCalories cal'),
                    if (filterDifficulty != null)
                      FilterChipWidget(label: filterDifficulty!),
                  ],
                ),
              ],
              AppGap.h16,

              // ── Ingredient input ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.inputFieldBg,
                        borderRadius: AppBorderRadius.a12,
                        border: Border.all(color: appColors.inputBorder),
                      ),
                      child: TextField(
                        controller: ingredientCtrl,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: appColors.textPrimary,
                            ),
                        decoration: InputDecoration(
                          hintText: 'search.add_ingredient'.tr(),
                          hintStyle: AppTextStyles.s14.copyWith(
                            color: appColors.inputHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            onAdd(v.trim());
                            ingredientCtrl.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final v = ingredientCtrl.text.trim();
                        if (v.isNotEmpty) {
                          onAdd(v);
                          ingredientCtrl.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.a12,
                        ),
                      ),
                      child: Icon(Icons.add_rounded, color: appColors.onPrimary),
                    ),
                  ),
                ],
              ),
              AppGap.h16,

              // ── Added chips ─────────────────────────────────────────────
              if (addedIngredients.isNotEmpty) ...[
                Text(
                  'search.added_count'.tr(
                    namedArgs: {'count': '${addedIngredients.length}'},
                  ),
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
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
                            color: appColors.chipSelectedText,
                          ),
                          backgroundColor: appColors.chipSelectedBg,
                          side: BorderSide(
                            color: appColors.chipSelectedBorder,
                            width: 1,
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onDeleted: () => onRemove(item),
                          padding: AppPad.h4,
                        ),
                      )
                      .toList(),
                ),
                AppGap.h16,
              ],

              // ── Common ingredients ──────────────────────────────────────
              Text(
                'search.common_ingredients'.tr(),
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
                        color: isAdded
                            ? appColors.chipSelectedBg
                            : appColors.chipBg,
                        borderRadius: AppBorderRadius.a12,
                        border: Border.all(
                          color: isAdded
                              ? appColors.chipSelectedBorder
                              : appColors.chipBorder,
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
                              : appColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── Search results (khi có query) ───────────────────────────
              if (provider.searchQuery.isNotEmpty) ...[
                AppGap.h24,
                Row(
                  children: [
                    Text(
                      'search.recipe_results'.tr(),
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                    AppGap.w8,
                    Container(
                      padding: AppPad.h8v4,
                      decoration: BoxDecoration(
                        color: appColors.chipSelectedBg,
                        borderRadius: AppBorderRadius.a8,
                        border: Border.all(color: appColors.chipSelectedBorder),
                      ),
                      child: Text(
                        '${provider.searchResults.length}',
                        style: AppTextStyles.s12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,
                if (provider.isLoading)
                  ...List.generate(
                    3,
                    (_) => Shimmer.fromColors(
                      baseColor: appColors.shimmerBase,
                      highlightColor: appColors.shimmerHighlight,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: appColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (_) {
                      var results = provider.searchResults;
                      if (filterMealType != null) {
                        results = results
                            .where((r) => r.mealType == filterMealType)
                            .toList();
                      }
                      if (filterMaxCalories != null) {
                        results = results
                            .where((r) => r.calories <= filterMaxCalories!)
                            .toList();
                      }
                      if (filterDifficulty != null) {
                        results = results
                            .where((r) => r.difficulty == filterDifficulty)
                            .toList();
                      }
                      if (results.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  '🔍',
                                  style: TextStyle(fontSize: 32),
                                ),
                                AppGap.h8,
                                Text(
                                  'search.no_results'.tr(),
                                  style: AppTextStyles.s14.copyWith(
                                    color: appColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: results
                            .map((r) => RecipeSearchResultTile(recipe: r))
                            .toList(),
                      );
                    },
                  ),
              ],

              // ── Recipe suggestions (khi chưa có query, có ingredient) ──
              if (provider.searchQuery.isEmpty &&
                  addedIngredients.isNotEmpty) ...[
                AppGap.h24,
                Row(
                  children: [
                    Text(
                      'search.recipe_suggestions'.tr(),
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                    AppGap.w8,
                    Container(
                      padding: AppPad.h8v4,
                      decoration: BoxDecoration(
                        color: appColors.chipSelectedBg,
                        borderRadius: AppBorderRadius.a8,
                        border: Border.all(color: appColors.chipSelectedBorder),
                      ),
                      child: Text(
                        '${provider.searchResults.length}',
                        style: AppTextStyles.s12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,
                ...provider.searchResults.map(
                  (r) => RecipeSuggestionTileWidget(
                    recipe: (
                      r.name,
                      '${r.calories} cal',
                      '${r.prepTime} min',
                      '🍽️',
                      90,
                    ),
                  ),
                ),
              ],

              AppGap.h80,
            ],
          ),
        );
      },
    );
  }
}
