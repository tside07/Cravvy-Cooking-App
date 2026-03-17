import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/nutrition_consistency_row.dart';
import '../widgets/achievement_card.dart';

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
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Progress',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            // Streak + stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    StatCard(
                      emoji: '🔥',
                      value: '7',
                      label: 'Day streak',
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 10),
                    StatCard(
                      emoji: '✅',
                      value: '23',
                      label: 'Meals logged',
                      color: AppColors.successLight,
                    ),
                    const SizedBox(width: 10),
                    StatCard(
                      emoji: '🎯',
                      value: '68%',
                      label: 'Goal hit',
                      color: AppColors.secondaryLight,
                    ),
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
                    Text(
                      'Weekly Calories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal: 2,200 kcal/day',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    const WeeklyBarChart(
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
                    Text(
                      'Nutrition Consistency',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const NutritionConsistencyRow(
                      label: 'Protein',
                      percent: 72,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    const NutritionConsistencyRow(
                      label: 'Carbs',
                      percent: 88,
                      color: AppColors.accentDark,
                    ),
                    const SizedBox(height: 10),
                    const NutritionConsistencyRow(
                      label: 'Fat',
                      percent: 55,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Achievements title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            // Achievement grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: _achievements
                    .map(
                      (a) => AchievementCard(
                        emoji: a.$1,
                        title: a.$2,
                        desc: a.$3,
                        unlocked: a.$4,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
