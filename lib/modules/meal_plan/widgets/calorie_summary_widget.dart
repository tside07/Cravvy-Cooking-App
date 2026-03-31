import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

class CalorieSummaryWidget extends StatelessWidget {
  const CalorieSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final day = provider.selectedDay;
        final remaining = provider.remainingCalories;

        return Container(
          margin: const EdgeInsets.only(
            left: 16,
            top: 14,
            right: 16,
          ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
          padding: AppPad.a18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppBorderRadius.a20,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _CalStat(
                    label: 'Consumed',
                    value: '${day.totalCalories}',
                    unit: 'kcal',
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        '${remaining > 0 ? remaining : 0}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'kcal left',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _CalStat(
                    label: 'Goal',
                    value: '${provider.targetCalories}',
                    unit: 'kcal',
                    alignRight: true,
                  ),
                ],
              ),
              AppGap.h14,
              ClipRRect(
                borderRadius: AppBorderRadius.a8,
                child: LinearProgressIndicator(
                  value: provider.calorieProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              AppGap.h16,
              Row(
                children: [
                  _MacroChip(
                    label: 'Protein',
                    value: '${day.totalProtein}g',
                    target: '${provider.targetProtein}g',
                    progress: provider.proteinProgress,
                    color: AppColors.secondary,
                  ),
                  AppGap.w8,
                  _MacroChip(
                    label: 'Carbs',
                    value: '${day.totalCarbs}g',
                    target: '${provider.targetCarbs}g',
                    progress: provider.carbsProgress,
                    color: AppColors.accent,
                  ),
                  AppGap.w8,
                  _MacroChip(
                    label: 'Fat',
                    value: '${day.totalFat}g',
                    target: '${provider.targetFat}g',
                    progress: provider.fatProgress,
                    color: Colors.white,
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

// ─── Private sub-widgets ─────────────────────────────────────────────────────

class _CalStat extends StatelessWidget {
  const _CalStat({
    required this.label,
    required this.value,
    required this.unit,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final String target;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppPad.h10v8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: AppBorderRadius.a12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            AppGap.h2,
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            AppGap.h4,
            ClipRRect(
              borderRadius: AppBorderRadius.a4,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            AppGap.h2,
            Text(
              '/ $target',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
