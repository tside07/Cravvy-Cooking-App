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
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
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
                        style: AppTextStyles.s20.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'kcal left',
                        style: AppTextStyles.s12.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
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
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: provider.calorieProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MacroChip(
                    label: 'Protein',
                    value: '${day.totalProtein}g',
                    target: '${provider.targetProtein}g',
                    progress: provider.proteinProgress,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _MacroChip(
                    label: 'Carbs',
                    value: '${day.totalCarbs}g',
                    target: '${provider.targetCarbs}g',
                    progress: provider.carbsProgress,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
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
          style: AppTextStyles.s12.copyWith(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.s18.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTextStyles.s12.copyWith(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.s12.copyWith(
                fontSize: 10,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '/ $target',
              style: AppTextStyles.s12.copyWith(
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
