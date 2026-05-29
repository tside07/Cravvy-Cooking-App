import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/all_recipes_args.dart';
import 'package:cravvy_cooking_app/core/utils/featured_recipes_utils.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/recipe_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedRecipesWidget extends StatefulWidget {
  const FeaturedRecipesWidget({super.key});

  @override
  State<FeaturedRecipesWidget> createState() => _FeaturedRecipesWidgetState();
}

class _FeaturedRecipesWidgetState extends State<FeaturedRecipesWidget> {
  String _selectedType = 'all';

  static const _typeTabs = [
    ('all', 'home.tab_all', '🍽️'),
    ('breakfast', 'home.tab_breakfast', '🌅'),
    ('lunch', 'home.tab_lunch', '☀️'),
    ('dinner', 'home.tab_dinner', '🌙'),
    ('snack', 'home.tab_snack', '🍎'),
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
                    top: 24,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'home.recipes_title'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall,
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
                        child: Text('home.recipes_see_all'.tr()),
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
                      final (type, labelKey, emoji) = _typeTabs[i];
                      final isSelected = _selectedType == type;
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
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '$emoji ${labelKey.tr()}',
                            style: AppTextStyles.s12.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
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
    RecipeProvider provider, {
    required double horizontalPadding,
  }) {
    if (provider.isLoading || provider.status == RecipeStatus.initial) {
      return _buildShimmer(horizontalPadding: horizontalPadding);
    }

    if (provider.status == RecipeStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 32)),
            AppGap.h8,
            Text(
              'home.load_error'.tr(),
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
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
            const Text('🔍', style: TextStyle(fontSize: 28)),
            AppGap.h8,
            Text(
              'home.no_recipes'.tr(),
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
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
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.surface,
        child: Container(
          width: 180,
          height: 240,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
