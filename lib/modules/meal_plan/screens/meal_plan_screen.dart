import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/calorie_summary_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/free_week_upsell_banner.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_card_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_plan_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/week_strip_widget.dart';

import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

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
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    const MealPlanHeaderWidget(),
                    const WeekStripWidget(),
                    const FreeWeekUpsellBanner(),
                    const CalorieSummaryWidget(),
                    Expanded(
                      child: _MealList(horizontalPadding: horizontalPadding),
                    ),
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

class _MealList extends StatelessWidget {
  const _MealList({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.selectedDay.meals;
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 100),
          itemCount: meals.length,
          itemBuilder: (context, i) => MealCardWidget(
            meal: meals[i],
            onToggle: () => provider.toggleMealLogged(meals[i].id),
            onSwap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: MealSwapSheet(meal: meals[i]),
              ),
            ),
          ),
        );
      },
    );
  }
}
