import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/nutrition_ring_card.dart';
import '../widgets/today_meals_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/nutrition_tip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            const SliverToBoxAdapter(child: NutritionRingCard()),
            const SliverToBoxAdapter(child: TodayMealsSection()),
            const SliverToBoxAdapter(child: QuickActionsGrid()),
            const SliverToBoxAdapter(child: NutritionTip()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
