import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_stats_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_tabs_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_servings_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_ingredients_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_nutrition_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/widgets/meal_detail_instructions_widget.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MealDetailProvider(
        meal,
        recipeLookup: ctx.read<RecipeProvider>(),
      ),
      child: Scaffold(
        body: _MealDetailBody(meal: meal),
      ),
    );
  }
}

class _MealDetailBody extends StatelessWidget {
  const _MealDetailBody({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Consumer<MealDetailProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: CustomScrollView(
                  slivers: [
                    // ── Hero image + title + tags ───────────────────────────────────
                    MealDetailHeaderWidget(meal: meal),

            // ── White content card that peeks over the image ────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle (decorative)
                    Padding(
                      padding: AppPad.t12,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: AppBorderRadius.a8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

                    // ── Stats row (prep / cal / servings / level) ───────────────────
                    MealDetailStatsWidget(meal: meal),

                    // ── Divider ─────────────────────────────────────────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                    ),

                    // ── Tab bar ──────────────────────────────────────────────────────
                    const MealDetailTabsWidget(),

                    // ── Tab-specific content ─────────────────────────────────────────
                    if (provider.activeTab == MealDetailTab.ingredients) ...[
                      const MealDetailServingsWidget(),
                      MealDetailIngredientsWidget(mealName: meal.name),
                    ] else if (provider.activeTab == MealDetailTab.nutrition)
                      MealDetailNutritionWidget(meal: meal)
                    else
                      MealDetailInstructionsWidget(meal: meal),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
