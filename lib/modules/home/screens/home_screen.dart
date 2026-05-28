import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/home_header_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/nutrition_ring_card_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/today_meals_section_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/quick_actions_grid_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/featured_recipes_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/nutrition_tip_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = _responsiveHorizontalPadding(
              constraints.maxWidth,
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: HomeHeaderWidget()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: NutritionRingCardWidget()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: TodayMealsSectionWidget()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: QuickActionsGridWidget()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: FeaturedRecipesWidget()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: const SliverToBoxAdapter(child: NutritionTipWidget()),
                    ),
                    AppGap.sh100,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _responsiveHorizontalPadding(double maxWidth) {
    if (maxWidth >= 1024) return 32;
    if (maxWidth >= 768) return 24;
    if (maxWidth >= 600) return 20;
    return 16;
  }
}
