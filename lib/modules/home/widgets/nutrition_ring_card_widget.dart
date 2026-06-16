import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/macro_bar_widget.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/ring_painter_widget.dart';

class NutritionRingCardWidget extends StatelessWidget {
  const NutritionRingCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when locale changes (.tr() alone does not subscribe).
    // Source: https://pub.dev/documentation/easy_localization/latest/easy_localization/EasyLocalization/of.html
    final _ = context.locale;

    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final colors = context.appColors;
        final day = provider.todayDay;
        final remaining =
            (provider.targetCalories - day.totalCalories).clamp(0, 9999);
        final progress =
            (day.totalCalories / provider.targetCalories).clamp(0.0, 1.0);

        return Container(
          margin: AppPad.section16t20,
          padding: AppPad.a20,
          decoration: context.cardBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.nutrition_title'.tr(),
                style: context.themed(AppTextStyles.h2),
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
                          painter: RingPainterWidget(
                            progress: progress,
                            trackColor: colors.elevated,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$remaining',
                                style: context.themed(
                                  AppTextStyles.display.copyWith(
                                    fontSize: 34,
                                    height: 1,
                                  ),
                                ),
                              ),
                              Text(
                                'home.kcal_left'.tr(),
                                style: context.themed(
                                  AppTextStyles.s12.copyWith(fontSize: 11),
                                  color: colors.textSecondary,
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
                          label: 'home.macro_protein'.tr(),
                          current: day.totalProtein,
                          target: provider.targetProtein,
                          unit: 'g',
                          color: AppColors.secondary,
                        ),
                        AppGap.h12,
                        MacroBarWidget(
                          label: 'home.macro_carbs'.tr(),
                          current: day.totalCarbs,
                          target: provider.targetCarbs,
                          unit: 'g',
                          color: AppColors.accentDark,
                        ),
                        AppGap.h12,
                        MacroBarWidget(
                          label: 'home.macro_fat'.tr(),
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
