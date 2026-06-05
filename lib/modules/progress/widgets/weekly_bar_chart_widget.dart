import 'package:cravvy_cooking_app/init.dart';

class WeeklyBarChartWidget extends StatelessWidget {
  const WeeklyBarChartWidget({
    super.key,
    required this.data,
    required this.days,
    required this.goal,
  });

  final List<int> data;
  final List<String> days;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final peak = data.isEmpty
        ? 0.0
        : data.reduce((a, b) => a > b ? a : b).toDouble();
    // Empty week plan (e.g. logout) yields all zeros → peak 0 → 0/0 NaN heights.
    final max = (peak > 0 ? peak : 1.0) * 1.2;
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final barHeight = (data[i] / max) * 90;
          final isToday = i == today;
          final isGoalMet = data[i] >= goal * 0.9;
          final color = isToday
              ? AppColors.primary
              : isGoalMet
              ? AppColors.success
              : AppColors.border;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isToday)
                  Text(
                    '${data[i]}',
                    style: AppTextStyles.s10.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                AppGap.h2,
                Container(
                  height: barHeight,
                  margin: AppPad.h4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppBorderRadius.a6,
                  ),
                ),
                AppGap.h6,
                Text(
                  days[i],
                  style: AppTextStyles.s12.copyWith(
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isToday
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
