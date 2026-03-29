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
    final max = data.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final barHeight = (data[i] / max) * 110;
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
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 2),
                Container(
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days[i],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w500,
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
