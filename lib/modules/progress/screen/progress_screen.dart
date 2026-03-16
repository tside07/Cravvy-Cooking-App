import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _achievements = [
    ('🔥', '7-Day Streak', 'Logged meals 7 days in a row', true),
    ('🥗', 'Salad Lover', 'Ate salad 5 times', true),
    ('💧', 'Hydrated', 'Drank 2L water for 3 days', false),
    ('🏆', 'Goal Crusher', 'Hit calorie goal 10 times', false),
  ];

  static const _weeklyData = [820, 1980, 2100, 1650, 2200, 1800, 800];
  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text('Progress',
                    style: Theme.of(context).textTheme.headlineLarge),
              ),
            ),

            // Streak + stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    _StatCard(emoji: '🔥', value: '7', label: 'Day streak',
                        color: AppColors.primaryLight),
                    const SizedBox(width: 10),
                    _StatCard(emoji: '✅', value: '23', label: 'Meals logged',
                        color: AppColors.successLight),
                    const SizedBox(width: 10),
                    _StatCard(emoji: '🎯', value: '68%', label: 'Goal hit',
                        color: AppColors.secondaryLight),
                  ],
                ),
              ),
            ),

            // Weekly calorie chart
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly Calories',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Goal: 2,200 kcal/day',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    _WeeklyBarChart(
                      data: _weeklyData,
                      days: _weekDays,
                      goal: 2200,
                    ),
                  ],
                ),
              ),
            ),

            // Nutrition consistency
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nutrition Consistency',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    _NutritionConsistencyRow(
                      label: 'Protein', percent: 72,
                      color: AppColors.secondary),
                    const SizedBox(height: 10),
                    _NutritionConsistencyRow(
                      label: 'Carbs', percent: 88,
                      color: AppColors.accentDark),
                    const SizedBox(height: 10),
                    _NutritionConsistencyRow(
                      label: 'Fat', percent: 55,
                      color: AppColors.primary),
                  ],
                ),
              ),
            ),

            // Achievements
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text('Achievements',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: _achievements.map((a) {
                  final (emoji, title, desc, unlocked) = a;
                  return _AchievementCard(
                    emoji: emoji, title: title,
                    desc: desc, unlocked: unlocked,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.emoji, required this.value,
    required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
              fontFamily: 'Nunito', fontSize: 20,
              fontWeight: FontWeight.w800, color: AppColors.textPrimary,
            )),
            Text(label, style: const TextStyle(
              fontFamily: 'Nunito', fontSize: 10,
              color: AppColors.textSecondary,
            ), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<int> data;
  final List<String> days;
  final int goal;

  const _WeeklyBarChart({
    required this.data,
    required this.days,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final height = (data[i] / max) * 110;
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
                  height: height,
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

class _NutritionConsistencyRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;

  const _NutritionConsistencyRow({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('$percent%',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool unlocked;

  const _AchievementCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 22,
                  color: unlocked ? null : const Color(0x66000000),
                ),
              ),
              const Spacer(),
              if (unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('✓',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                )
              else
                const Icon(Icons.lock_outline_rounded,
                    size: 14, color: AppColors.textHint),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              color: AppColors.textHint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
