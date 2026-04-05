import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/macro_bar_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/ring_painter_widget.dart';

class NutritionRingCardWidget extends StatelessWidget {
  const NutritionRingCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final day = provider.selectedDay;
        final remaining = provider.remainingCalories.clamp(0, 9999);
        final progress = provider.calorieProgress;

        return Container(
          margin: const EdgeInsets.only(
            left: 16,
            top: 20,
            right: 16,
          ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
          padding: AppPad.a20,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.a24,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Nutrition",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppGap.h20,
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
                          painter: RingPainterWidget(progress: progress),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$remaining',
                                style: AppTextStyles.s20.copyWith(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'kcal left',
                                style: AppTextStyles.s12.copyWith(
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
                  AppGap.w20,

                  // Macro bars
                  Expanded(
                    child: Column(
                      children: [
                        MacroBarWidget(
                          label: 'Protein',
                          current: day.totalProtein,
                          target: provider.targetProtein,
                          unit: 'g',
                          color: AppColors.secondary,
                        ),
                        AppGap.h12,
                        MacroBarWidget(
                          label: 'Carbs',
                          current: day.totalCarbs,
                          target: provider.targetCarbs,
                          unit: 'g',
                          color: AppColors.accentDark,
                        ),
                        AppGap.h12,
                        MacroBarWidget(
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
