import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_plan_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/week_strip_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/calorie_summary_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_card_widget.dart';
import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const MealPlanHeaderWidget(),
            const WeekStripWidget(),
            const CalorieSummaryWidget(),
            const Expanded(child: _MealList()),
          ],
        ),
      ),
    );
  }
}

class _MealList extends StatelessWidget {
  const _MealList();

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.selectedDay.meals;
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: 100,
          ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
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
