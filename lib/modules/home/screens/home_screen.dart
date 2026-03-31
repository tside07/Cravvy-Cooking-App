import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/home_header_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/nutrition_ring_card_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/today_meals_section_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/quick_actions_grid_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/nutrition_tip_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeaderWidget()),
            const SliverToBoxAdapter(child: NutritionRingCardWidget()),
            const SliverToBoxAdapter(child: TodayMealsSectionWidget()),
            const SliverToBoxAdapter(child: QuickActionsGridWidget()),
            const SliverToBoxAdapter(child: NutritionTipWidget()),
            AppGap.sh100,
          ],
        ),
      ),
    );
  }
}
