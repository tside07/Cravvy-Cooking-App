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
        // Khi weekPlan chưa load xong — hiện skeleton với ngày tháng đúng
        // nhưng không đọc weekPlan[i] để tránh RangeError
        final weekStart = _currentWeekStart();

        return Container(
          height: 90,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: List.generate(7, (i) {
              final date = weekStart.add(Duration(days: i));
              final isSelected = provider.selectedDayIndex == i;
              final isToday = i == DateTime.now().weekday - 1;

              // Chỉ đọc weekPlan[i] khi đã loaded và đủ 7 ngày
              final hasPlan = provider.weekPlan.length == 7;
              final plan = hasPlan ? provider.weekPlan[i] : null;
              final hasAll = plan?.isComplete ?? false;
              final hasSome = (plan?.loggedCount ?? 0) > 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.selectDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: AppPad.v10,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: AppBorderRadius.a16,
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
                        AppGap.h4,
                        Text(
                          DateFormat('d').format(date),
                          style: AppTextStyles.s16.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        AppGap.h6,
                        // Dot indicator — ẩn khi chưa load xong
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !hasPlan
                                ? Colors.transparent
                                : hasAll
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

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
  }
}
