import 'package:cravvy_cooking_app/init.dart';
import 'package:intl/intl.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

class WeekStripWidget extends StatelessWidget {
  const WeekStripWidget({super.key});

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 90,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: List.generate(7, (i) {
              final plan = provider.weekPlan[i];
              final isSelected = provider.selectedDayIndex == i;
              final isToday = i == DateTime.now().weekday - 1;
              final hasAll = plan.isComplete;
              final hasSome = plan.loggedCount > 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.selectDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[i],
                          style: AppTextStyles.s12.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(plan.date),
                          style: AppTextStyles.s16.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasAll
                                ? AppColors.success
                                : hasSome
                                ? AppColors.warning
                                : isSelected
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
