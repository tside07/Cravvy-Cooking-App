import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'macro_bar.dart';
import 'ring_painter.dart';

class NutritionRingCard extends StatelessWidget {
  const NutritionRingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final day = provider.selectedDay;
        final remaining = provider.remainingCalories.clamp(0, 9999);
        final progress = provider.calorieProgress;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Nutrition",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Donut chart
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: const Size(130, 130),
                          painter: RingPainter(progress: progress),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$remaining',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                'kcal left',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Macro bars
                  Expanded(
                    child: Column(
                      children: [
                        MacroBar(
                          label: 'Protein',
                          current: day.totalProtein,
                          target: provider.targetProtein,
                          unit: 'g',
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 12),
                        MacroBar(
                          label: 'Carbs',
                          current: day.totalCarbs,
                          target: provider.targetCarbs,
                          unit: 'g',
                          color: AppColors.accentDark,
                        ),
                        const SizedBox(height: 12),
                        MacroBar(
                          label: 'Fat',
                          current: day.totalFat,
                          target: provider.targetFat,
                          unit: 'g',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
