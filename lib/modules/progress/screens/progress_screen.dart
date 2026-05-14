import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/stat_card_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/weekly_bar_chart_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/nutrition_consistency_row_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/achievement_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _weeklyData = [820, 1980, 2100, 1650, 2200, 1800, 800];

  @override
  Widget build(BuildContext context) {
    // Achievements: built at runtime to allow .tr()
    final achievements = [
      (
        '🔥',
        'progress.achievement.streak7_title'.tr(),
        'progress.achievement.streak7_desc'.tr(),
        true,
      ),
      (
        '🥗',
        'progress.achievement.salad_title'.tr(),
        'progress.achievement.salad_desc'.tr(),
        true,
      ),
      (
        '💧',
        'progress.achievement.hydrated_title'.tr(),
        'progress.achievement.hydrated_desc'.tr(),
        false,
      ),
      (
        '🏆',
        'progress.achievement.goal_crusher_title'.tr(),
        'progress.achievement.goal_crusher_desc'.tr(),
        false,
      ),
    ];

    final weekDays = [
      'progress.week_mo'.tr(),
      'progress.week_tu'.tr(),
      'progress.week_we'.tr(),
      'progress.week_th'.tr(),
      'progress.week_fr'.tr(),
      'progress.week_sa'.tr(),
      'progress.week_su'.tr(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, top: 20, right: 24),
                child: Text(
                  'progress.title'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            // Streak + stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
                child: Row(
                  children: [
                    StatCardWidget(
                      emoji: '🔥',
                      value: '7',
                      label: 'progress.stat_day_streak'.tr(),
                      color: AppColors.primaryLight,
                    ),
                    AppGap.w10,
                    StatCardWidget(
                      emoji: '✅',
                      value: '23',
                      label: 'progress.stat_meals_logged'.tr(),
                      color: AppColors.successLight,
                    ),
                    AppGap.w10,
                    StatCardWidget(
                      emoji: '🎯',
                      value: '68%',
                      label: 'progress.stat_goal_hit'.tr(),
                      color: AppColors.secondaryLight,
                    ),
                  ],
                ),
              ),
            ),

            // Weekly calorie chart
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
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
                      'progress.weekly_calories'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    AppGap.h4,
                    Text(
                      'progress.weekly_goal'.tr(namedArgs: {'kcal': '2,200'}),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppGap.h20,
                    WeeklyBarChartWidget(
                      data: _weeklyData,
                      days: weekDays,
                      goal: 2200,
                    ),
                  ],
                ),
              ),
            ),

            // Nutrition consistency
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(left: 16, top: 14, right: 16),
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
                      'progress.nutrition_consistency'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    AppGap.h16,
                    NutritionConsistencyRowWidget(
                      label: 'progress.nutrition_protein'.tr(),
                      percent: 72,
                      color: AppColors.secondary,
                    ),
                    AppGap.h10,
                    NutritionConsistencyRowWidget(
                      label: 'progress.nutrition_carbs'.tr(),
                      percent: 88,
                      color: AppColors.accentDark,
                    ),
                    AppGap.h10,
                    NutritionConsistencyRowWidget(
                      label: 'progress.nutrition_fat'.tr(),
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
                padding: const EdgeInsets.only(left: 24, top: 20, right: 24),
                child: Text(
                  'progress.achievements'.tr(),
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
              ),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: achievements
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
