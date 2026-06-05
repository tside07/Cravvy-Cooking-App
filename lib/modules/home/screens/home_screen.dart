import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/home_banner_carousel_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/today_meals_section_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/quick_actions_grid_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/nutrition_tip_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/featured_recipes_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: CustomAppBar(greeting: true)),
            const SliverToBoxAdapter(child: HomeBannerCarouselWidget()),
            const SliverToBoxAdapter(child: TodayMealsSectionWidget()),
            const SliverToBoxAdapter(child: FeaturedRecipesWidget()),
            const SliverToBoxAdapter(child: QuickActionsGridWidget()),
            const SliverToBoxAdapter(child: NutritionTipWidget()),
            AppGap.sh20,
          ],
        ),
      ),
    );
  }
}
