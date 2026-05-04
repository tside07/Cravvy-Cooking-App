// lib/modules/home/widgets/featured_recipes_widget.dart
//
// Section mới trên Home screen hiển thị recipes thật từ Supabase.
// Thêm vào HomeScreen DƯỚI TodayMealsSectionWidget.
// Có tab lọc theo meal type + loading/error state.

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

  static const _tabs = [
    ('all', 'All', '🍽️'),
    ('breakfast', 'Breakfast', '🌅'),
    ('lunch', 'Lunch', '☀️'),
    ('dinner', 'Dinner', '🌙'),
    ('snack', 'Snack', '🍎'),
  ];

  @override
  void initState() {
    super.initState();
    // Load recipes lần đầu nếu chưa có
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

            // ── Filter tabs ──────────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (type, label, emoji) = _tabs[i];
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
            AppGap.h12,

            // ── Content ──────────────────────────────────────────────────────
            SizedBox(height: 220, child: _buildContent(provider)),
          ],
        );
      },
    );
  }

  Widget _buildContent(RecipeProvider provider) {
    // Loading state
    if (provider.isLoading || provider.status == RecipeStatus.initial) {
      return _buildShimmer();
    }

    // Error state
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

    // Loaded state — filter theo tab
    final recipes = switch (_selectedType) {
      'breakfast' => provider.breakfastRecipes,
      'lunch' => provider.lunchRecipes,
      'dinner' => provider.dinnerRecipes,
      'snack' => provider.snackRecipes,
      _ => provider.allRecipes,
    };

    if (recipes.isEmpty) {
      return Center(
        child: Text(
          'Chưa có món ăn nào',
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
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
