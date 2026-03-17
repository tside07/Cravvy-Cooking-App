import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'meal_scroll_card.dart';

class TodayMealsSection extends StatelessWidget {
  const TodayMealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.selectedDay.meals;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Meals",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: meals.length,
                itemBuilder: (context, i) =>
                    MealScrollCard(meal: meals[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}
