import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/all_recipes_args.dart';
import 'package:cravvy_cooking_app/core/utils/featured_recipes_utils.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/recipe_card_widget.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton_layouts.dart';
import 'package:easy_localization/easy_localization.dart';

class FeaturedRecipesWidget extends StatefulWidget {
  const FeaturedRecipesWidget({super.key});

  @override
  State<FeaturedRecipesWidget> createState() => _FeaturedRecipesWidgetState();
}

class _FeaturedRecipesWidgetState extends State<FeaturedRecipesWidget> {
  String _selectedType = 'all';

  static const _typeTabs = <(String, String, IconData)>[
    ('all', 'home.tab_all', Icons.restaurant_rounded),
    ('breakfast', 'home.tab_breakfast', Icons.wb_twilight_rounded),
    ('lunch', 'home.tab_lunch', Icons.wb_sunny_rounded),
    ('dinner', 'home.tab_dinner', Icons.nightlight_round),
    ('snack', 'home.tab_snack', Icons.cookie_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final colors = context.appColors;

    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 768 ? 24.0 : 20.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding + 4,
                    right: horizontalPadding + 4,
                    top: 8,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'home.recipes_title'.tr(),
                          style: context.themed(AppTextStyles.h2),
                        ),
                      ),
                      TextButton(
                        onPressed: provider.isLoaded
                            ? () => context.push(
                                  AppRouter.allRecipes,
                                  extra: AllRecipesArgs(
                                    initialMealType: _selectedType,
                                  ),
                                )
                            : null,
                        child: Row(
                          children: [
                            Text(
                              'home.see_all'.tr(),
                              style: AppTextStyles.s12.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    itemCount: _typeTabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final (type, labelKey, icon) = _typeTabs[i];
                      final isSelected = _selectedType == type;
                      final tabColor = isSelected
                          ? Colors.white
                          : colors.textSecondary;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : colors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : colors.borderDivider,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 14, color: tabColor),
                              const SizedBox(width: 5),
                              Text(
                                labelKey.tr(),
                                style: AppTextStyles.s12.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tabColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppGap.h10,
                SizedBox(
                  height: 260,
                  child: _buildContent(
                    context,
                    provider,
                    horizontalPadding: horizontalPadding,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    RecipeProvider provider, {
    required double horizontalPadding,
  }) {
    final colors = context.appColors;

    if (provider.isLoading || provider.status == RecipeStatus.initial) {
      return _buildShimmer(horizontalPadding: horizontalPadding);
    }

    if (provider.status == RecipeStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 32,
              color: colors.textSecondary,
            ),
            AppGap.h8,
            Text(
              'home.load_error'.tr(),
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
            ),
            AppGap.h8,
            TextButton(
              onPressed: provider.reload,
              child: Text(
                'home.retry'.tr(),
                style: AppTextStyles.s14.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    final filterKey = buildFeaturedFilterKey(_selectedType, null);
    final recipes = provider.featuredRecipes(
      filterKey: filterKey,
      mealType: _selectedType,
    );

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 28,
              color: colors.textSecondary,
            ),
            AppGap.h8,
            Text(
              'home.no_recipes'.tr(),
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: recipes.length,
      itemBuilder: (_, i) => RecipeCardWidget(
        recipe: recipes[i],
        layout: RecipeCardLayout.featured,
      ),
    );
  }

  Widget _buildShimmer({required double horizontalPadding}) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: 4,
      itemBuilder: (_, _) => const RecipeCardSkeleton(),
    );
  }
}
