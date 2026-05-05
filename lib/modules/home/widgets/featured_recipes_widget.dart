// lib/modules/home/widgets/featured_recipes_widget.dart
//
// Tuần 3: Thêm Quick Filter tags (High Protein, Vegan, Quick, Low Carb)
// bên dưới meal type tabs. Filter hoạt động locally trên _allRecipes.

import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/recipe_card_widget.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedRecipesWidget extends StatefulWidget {
  const FeaturedRecipesWidget({super.key});

  @override
  State<FeaturedRecipesWidget> createState() => _FeaturedRecipesWidgetState();
}

class _FeaturedRecipesWidgetState extends State<FeaturedRecipesWidget> {
  String _selectedType = 'all';
  String? _selectedTag;

  static const _typeTabs = [
    ('all', 'All', '🍽️'),
    ('breakfast', 'Breakfast', '🌅'),
    ('lunch', 'Lunch', '☀️'),
    ('dinner', 'Dinner', '🌙'),
    ('snack', 'Snack', '🍎'),
  ];

  static const _quickTags = [
    'High Protein',
    'Quick',
    'Vegan',
    'Low Carb',
    'Gluten-Free',
    'Meal Prep',
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
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explore Recipes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (provider.isLoaded)
                    Text(
                      '${provider.allRecipes.length} recipes',
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // ── Meal type tabs ───────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _typeTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (type, label, emoji) = _typeTabs[i];
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = type;
                      _selectedTag = null; // reset tag filter
                    }),
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
                        '$emoji $label',
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

            // ── Quick tag filters ────────────────────────────────────────────
            if (provider.isLoaded) ...[
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _quickTags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final tag = _quickTags[i];
                    final isActive = _selectedTag == tag;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTag = isActive ? null : tag),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryLight
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.s12.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppGap.h10,
            ],

            // ── Recipe cards ─────────────────────────────────────────────────
            SizedBox(height: 220, child: _buildContent(provider)),
          ],
        );
      },
    );
  }

  Widget _buildContent(RecipeProvider provider) {
    if (provider.isLoading || provider.status == RecipeStatus.initial) {
      return _buildShimmer();
    }

    if (provider.status == RecipeStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 32)),
            AppGap.h8,
            Text(
              'Không tải được dữ liệu',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
            AppGap.h8,
            TextButton(
              onPressed: provider.reload,
              child: Text(
                'Thử lại',
                style: AppTextStyles.s14.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    // Lọc theo type tab
    var recipes = switch (_selectedType) {
      'breakfast' => provider.breakfastRecipes,
      'lunch' => provider.lunchRecipes,
      'dinner' => provider.dinnerRecipes,
      'snack' => provider.snackRecipes,
      _ => provider.allRecipes,
    };

    // Lọc thêm theo tag nếu đang active
    if (_selectedTag != null) {
      recipes = recipes.where((r) => r.tags.contains(_selectedTag)).toList();
    }

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 28)),
            AppGap.h8,
            Text(
              _selectedTag != null
                  ? 'No "$_selectedTag" recipes found'
                  : 'Chưa có món ăn nào',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recipes.length,
      itemBuilder: (_, i) => RecipeCardWidget(recipe: recipes[i]),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.surface,
        child: Container(
          width: 160,
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
