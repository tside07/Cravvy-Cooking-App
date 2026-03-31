import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/stat_card_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/weekly_bar_chart_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/nutrition_consistency_row_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/achievement_card_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _achievements = [
    ('🔥', '7-Day Streak', 'Logged meals 7 days in a row', true),
    ('🥗', 'Salad Lover', 'Ate salad 5 times', true),
    ('💧', 'Hydrated', 'Drank 2L water for 3 days', false),
    ('🏆', 'Goal Crusher', 'Hit calorie goal 10 times', false),
  ];

  static const _weeklyData = [820, 1980, 2100, 1650, 2200, 1800, 800];
  static const _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

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
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 20,
                  right: 24,
                ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
                child: Text(
                  'Progress',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            // Streak + stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 20,
                  right: 16,
                ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
                child: Row(
                  children: [
                    StatCardWidget(
                      emoji: '🔥',
                      value: '7',
                      label: 'Day streak',
                      color: AppColors.primaryLight,
                    ),
                    AppGap.w10,
                    StatCardWidget(
                      emoji: '✅',
                      value: '23',
                      label: 'Meals logged',
                      color: AppColors.successLight,
                    ),
                    AppGap.w10,
                    StatCardWidget(
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
                margin: const EdgeInsets.only(
                  left: 16,
                  top: 16,
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
                      'Weekly Calories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    AppGap.h4,
                    Text(
                      'Goal: 2,200 kcal/day',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppGap.h20,
                    const WeeklyBarChartWidget(
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
                margin: const EdgeInsets.only(
                  left: 16,
                  top: 14,
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
                      'Nutrition Consistency',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    AppGap.h16,
                    const NutritionConsistencyRowWidget(
                      label: 'Protein',
                      percent: 72,
                      color: AppColors.secondary,
                    ),
                    AppGap.h10,
                    const NutritionConsistencyRowWidget(
                      label: 'Carbs',
                      percent: 88,
                      color: AppColors.accentDark,
                    ),
                    AppGap.h10,
                    const NutritionConsistencyRowWidget(
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
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 20,
                  right: 24,
                ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
                child: Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            // Achievement grid
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 12,
                right: 16,
                bottom: 100,
              ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: _achievements
                    .map(
                      (a) => AchievementCardWidget(
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
