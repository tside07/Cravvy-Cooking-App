import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/utils/profile_recipe_filter.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/models/ingredient_suggestion.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/data/services/ingredient_suggest_service.dart';
import 'package:cravvy_cooking_app/modules/search/provider/ingredient_suggest_provider.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_search_result_tile.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_suggestion_tile_widget.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton_layouts.dart';
import 'package:easy_localization/easy_localization.dart';

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
    required this.onSuggestAi,
    required this.conflicts,
    required this.riskAcknowledged,
    required this.onAcknowledgeRisk,
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
  final VoidCallback onSuggestAi;

  /// Ingredients the user entered that clash with their saved profile.
  final List<IngredientConflict> conflicts;

  /// True once the user accepted the risk of those conflicts.
  final bool riskAcknowledged;
  final VoidCallback onAcknowledgeRisk;
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
                        borderRadius: AppBorderRadius.button,
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
                  Pressable(
                    onTap: onFilterTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasActiveFilter
                            ? AppColors.primary
                            : appColors.inputFieldBg,
                        borderRadius: AppBorderRadius.button,
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
                          borderRadius: AppBorderRadius.button,
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
                style: context.themed(
                  AppTextStyles.s14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppGap.h10,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonIngredients.map((item) {
                  final isAdded = addedIngredients.contains(item);
                  return Pressable(
                    onTap: () => onAdd(item),
                    child: AnimatedContainer(
                      duration: (MediaQuery.maybeDisableAnimationsOf(context) ??
                              false)
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      padding: AppPad.h12v8,
                      decoration: BoxDecoration(
                        color: isAdded
                            ? appColors.chipSelectedBg
                            : appColors.chipBg,
                        borderRadius: AppBorderRadius.chip,
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

              // ── AI disclaimer (only on the empty / browse state) ────────
              if (addedIngredients.isEmpty) ...[
                AppGap.h16,
                const _AiDisclaimer(),
              ],

              // ── AI suggest button + results ─────────────────────────────
              if (addedIngredients.isNotEmpty) ...[
                AppGap.h16,
                if (conflicts.isNotEmpty) ...[
                  _ConflictBanner(
                    conflicts: conflicts,
                    acknowledged: riskAcknowledged,
                    onAcknowledge: onAcknowledgeRisk,
                  ),
                  AppGap.h12,
                ],
                _AiSuggestButton(
                  onTap: onSuggestAi,
                  blocked: conflicts.isNotEmpty && !riskAcknowledged,
                ),
                const _AiSuggestResults(),
              ],

              // ── Search results (khi có query) ───────────────────────────
              if (provider.searchQuery.isNotEmpty) ...[
                AppGap.h24,
                Row(
                  children: [
                    Text(
                      'search.recipe_results'.tr(),
                      style: context.themed(AppTextStyles.h2),
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
                  ...List.generate(3, (_) => const ListRowSkeleton())
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
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 32,
                                  color: appColors.textSecondary,
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
                      style: context.themed(AppTextStyles.h2),
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
                      Icons.restaurant_rounded,
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

// ─── AI disclaimer (shown in the empty/browse state) ──────────────────────────
class _AiDisclaimer extends StatelessWidget {
  const _AiDisclaimer();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.a12,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.a12,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'search.ai_disclaimer_title'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                AppGap.h4,
                Text(
                  'search.ai_disclaimer_body'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile conflict banner (danger) ─────────────────────────────────────────
/// Localizes a profile rule (diet or avoid label) for display.
String _localizeRule(String rule) {
  switch (rule) {
    case 'Vegan':
      return 'onboarding_setup.diet_vegan'.tr();
    case 'Vegetarian':
      return 'onboarding_setup.diet_vegetarian'.tr();
    case 'Gluten-Free':
      return 'onboarding_setup.diet_gluten_free'.tr();
    case 'Peanuts':
      return 'onboarding_setup.allergy_peanuts'.tr();
    case 'Shellfish':
      return 'onboarding_setup.allergy_shellfish'.tr();
    case 'Dairy':
      return 'onboarding_setup.allergy_dairy'.tr();
    case 'Gluten':
      return 'onboarding_setup.allergy_gluten'.tr();
    case 'Eggs':
      return 'onboarding_setup.allergy_eggs'.tr();
    case 'Soy':
      return 'onboarding_setup.allergy_soy'.tr();
    case 'Tree Nuts':
      return 'onboarding_setup.allergy_tree_nuts'.tr();
    case 'Fish':
      return 'onboarding_setup.allergy_fish'.tr();
    case 'No Pork':
      return 'onboarding_setup.pref_no_pork'.tr();
    case 'No Beef':
      return 'onboarding_setup.pref_no_beef'.tr();
    case 'No Seafood':
      return 'onboarding_setup.pref_no_seafood'.tr();
    case 'No Spicy':
      return 'onboarding_setup.pref_no_spicy'.tr();
    case 'No Raw Foods':
      return 'onboarding_setup.pref_no_raw_foods'.tr();
    default:
      return rule; // custom avoid entries
  }
}

class _ConflictBanner extends StatelessWidget {
  const _ConflictBanner({
    required this.conflicts,
    required this.acknowledged,
    required this.onAcknowledge,
  });

  final List<IngredientConflict> conflicts;
  final bool acknowledged;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final items =
        conflicts.map((c) => c.ingredient).toSet().join(', ');
    final rules =
        conflicts.map((c) => _localizeRule(c.rule)).toSet().join(', ');
    final hasAllergen = conflicts.any((c) => c.isAllergen);

    return Container(
      padding: AppPad.a14,
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppBorderRadius.a14,
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gpp_maybe_rounded,
                size: 20,
                color: AppColors.error,
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  'search.conflict_title'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h8,
          Text(
            'search.conflict_body'.tr(
              namedArgs: {'rules': rules, 'items': items},
            ),
            style: AppTextStyles.s12.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (hasAllergen) ...[
            AppGap.h6,
            Text(
              'search.conflict_allergen'.tr(),
              style: AppTextStyles.s12.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ],
          AppGap.h12,
          if (acknowledged)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                AppGap.w6,
                Expanded(
                  child: Text(
                    'search.conflict_acknowledged'.tr(),
                    style: AppTextStyles.s12.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: Text(
                  'search.conflict_continue'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: AppPad.v12,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.a12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── AI suggest button ────────────────────────────────────────────────────────
class _AiSuggestButton extends StatelessWidget {
  const _AiSuggestButton({required this.onTap, this.blocked = false});

  final VoidCallback onTap;

  /// Disabled while unresolved profile conflicts exist.
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<IngredientSuggestProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (loading || blocked) ? null : onTap,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text(
          loading ? 'search.ai_loading'.tr() : 'search.ai_suggest_btn'.tr(),
          style: AppTextStyles.s14.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: AppPad.v14,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a14),
        ),
      ),
    );
  }
}

// ─── AI suggest results ───────────────────────────────────────────────────────
class _AiSuggestResults extends StatelessWidget {
  const _AiSuggestResults();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IngredientSuggestProvider>();

    switch (provider.status) {
      case SuggestStatus.idle:
        return const SizedBox.shrink();

      case SuggestStatus.loading:
        return Padding(
          padding: AppPad.t12,
          child: Column(
            children: List.generate(3, (_) => const ListRowSkeleton()),
          ),
        );

      case SuggestStatus.error:
        return Padding(
          padding: AppPad.t12,
          child: _NoticeBox(
            icon: Icons.error_outline_rounded,
            message: _errorMessage(provider.lastError),
          ),
        );

      case SuggestStatus.loaded:
        if (!provider.hasResults) {
          return Padding(
            padding: AppPad.t12,
            child: _NoticeBox(
              icon: Icons.search_off_rounded,
              message: 'search.ai_empty'.tr(),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGap.h16,
            Text(
              'search.ai_results_title'.tr(),
              style: context.themed(AppTextStyles.h2),
            ),
            if (!provider.sufficient) ...[
              AppGap.h8,
              _NoticeBox(
                icon: Icons.warning_amber_rounded,
                message: 'search.ai_low_confidence'.tr(),
                isWarning: true,
              ),
            ],
            if (provider.aiUnavailable) ...[
              AppGap.h8,
              _NoticeBox(
                icon: Icons.info_outline_rounded,
                message: 'search.ai_unavailable_note'.tr(),
              ),
            ],
            AppGap.h12,
            ...provider.suggestions.map(
              (s) => _SuggestionCard(suggestion: s),
            ),
          ],
        );
    }
  }

  String _errorMessage(IngredientSuggestException? e) {
    switch (e?.kind) {
      case SuggestErrorKind.dailyLimit:
        return 'search.ai_daily_limit'.tr();
      default:
        return 'search.ai_error'.tr();
    }
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({
    required this.icon,
    required this.message,
    this.isWarning = false,
  });

  final IconData icon;
  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = isWarning ? AppColors.warningLight : colors.elevated;
    final border = isWarning ? AppColors.warning : colors.borderDivider;
    final fg = isWarning ? AppColors.warning : colors.textSecondary;
    final textColor = isWarning ? AppColors.textPrimary : colors.textSecondary;
    return Container(
      padding: AppPad.a12,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.a12,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          AppGap.w8,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.s12.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final IngredientSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final meal = suggestion.toMeal();
    final colors = context.appColors;

    return Padding(
      padding: AppPad.b10,
      child: PressableCard(
        onTap: () => context.push(AppRouter.mealDetail, extra: meal),
        radius: 16,
        child: Row(
          children: [
            // Image (real) or meal-type icon placeholder.
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 76,
                height: 76,
                child: (suggestion.imageUrl != null &&
                        suggestion.imageUrl!.isNotEmpty)
                    ? Image.network(
                        suggestion.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _iconPlaceholder(meal),
                      )
                    : _iconPlaceholder(meal),
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppPad.a12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.name,
                            style: context.themed(
                              AppTextStyles.s14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (suggestion.isAiGenerated) ...[
                          AppGap.w6,
                          Container(
                            padding: AppPad.h6v2,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: AppBorderRadius.a6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                                AppGap.w2,
                                Text(
                                  'search.ai_badge'.tr(),
                                  style: AppTextStyles.s10.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppGap.h4,
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        AppGap.w2,
                        Text(
                          '${suggestion.calories} ${'meal_plan.calories_unit'.tr()}',
                          style: AppTextStyles.s12.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        AppGap.w10,
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: colors.textSecondary,
                        ),
                        AppGap.w2,
                        Text(
                          '${suggestion.prepTime}${'meal_plan.minutes_short'.tr()}',
                          style: AppTextStyles.s12.copyWith(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (suggestion.missingIngredients.isNotEmpty) ...[
                      AppGap.h4,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          AppGap.w4,
                          Expanded(
                            child: Text(
                              'search.ai_need_more'.tr(
                                namedArgs: {
                                  'items':
                                      suggestion.missingIngredients.join(', '),
                                },
                              ),
                              style: AppTextStyles.s10.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPlaceholder(Meal meal) => ColoredBox(
        color: meal.type.lightColor,
        child: Center(
          child: Icon(meal.type.icon, size: 30, color: meal.type.color),
        ),
      );
}
