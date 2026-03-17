import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import '../widgets/meal_plan_header.dart';
import '../widgets/week_strip.dart';
import '../widgets/calorie_summary.dart';
import '../widgets/meal_card.dart';
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
            const MealPlanHeader(),
            const WeekStrip(),
            const CalorieSummary(),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: meals.length,
          itemBuilder: (context, i) => MealCard(
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
