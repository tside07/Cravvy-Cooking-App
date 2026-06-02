import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/common/widgets/centered_loading.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/stat_card_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/weekly_bar_chart_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/nutrition_consistency_row_widget.dart';
import 'package:cravvy_cooking_app/modules/progress/widgets/achievement_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

/// Weekly bar heights from [MealPlanProvider.weekPlan] (Mon–Sun).
List<int> _weeklyCaloriesFromWeekPlan(List<DayPlan> weekPlan) {
  if (weekPlan.isEmpty) return [0, 0, 0, 0, 0, 0, 0];
  return weekPlan.map((d) => d.totalCalories).toList();
}

/// Progress tab stat row: streak, meals logged, goal-hit rate.
class WeekProgressStats {
  const WeekProgressStats({
    required this.streak,
    required this.mealsLogged,
    required this.goalHitPercent,
  });

  final int streak;
  final int mealsLogged;
  final int goalHitPercent;
}

/// Weekly macro adherence for nutrition consistency rows.
class WeekNutritionConsistency {
  const WeekNutritionConsistency({
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  final int proteinPercent;
  final int carbsPercent;
  final int fatPercent;
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  /// Test entry point for [_buildWeekStats].
  static WeekProgressStats buildWeekStats(
    List<DayPlan> weekPlan,
    int targetCalories, {
    int? todayIndex,
  }) =>
      _buildWeekStats(weekPlan, targetCalories, todayIndex: todayIndex);

  /// [todayIndex] Mon=0 … Sun=6; defaults to calendar today in UI.
  static WeekProgressStats _buildWeekStats(
    List<DayPlan> weekPlan,
    int targetCalories, {
    int? todayIndex,
  }) {
    if (weekPlan.isEmpty) {
      return const WeekProgressStats(
        streak: 0,
        mealsLogged: 0,
        goalHitPercent: 0,
      );
    }

    final today = todayIndex ?? DateTime.now().weekday - 1;
    final clampedToday = today.clamp(0, weekPlan.length - 1);

    var streak = 0;
    for (var i = clampedToday; i >= 0; i--) {
      if (weekPlan[i].loggedCount <= 0) break;
      streak++;
    }

    final mealsLogged = weekPlan.fold<int>(0, (sum, d) => sum + d.loggedCount);

    final calorieThreshold = targetCalories * 0.9;
    final goalHitDays = weekPlan
        .where((d) => d.totalCalories >= calorieThreshold)
        .length;
    final goalHitPercent = ((goalHitDays / 7) * 100).round();

    return WeekProgressStats(
      streak: streak,
      mealsLogged: mealsLogged,
      goalHitPercent: goalHitPercent,
    );
  }

  static WeekNutritionConsistency _buildNutritionConsistency(
    List<DayPlan> weekPlan, {
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
  }) {
    int macroPercent(int weekTotal, int dailyTarget) {
      if (dailyTarget <= 0) return 0;
      final weeklyTarget = dailyTarget * 7;
      return ((weekTotal / weeklyTarget) * 100).clamp(0, 100).round();
    }

    final proteinTotal =
        weekPlan.fold<int>(0, (sum, d) => sum + d.totalProtein);
    final carbsTotal = weekPlan.fold<int>(0, (sum, d) => sum + d.totalCarbs);
    final fatTotal = weekPlan.fold<int>(0, (sum, d) => sum + d.totalFat);

    return WeekNutritionConsistency(
      proteinPercent: macroPercent(proteinTotal, targetProtein),
      carbsPercent: macroPercent(carbsTotal, targetCarbs),
      fatPercent: macroPercent(fatTotal, targetFat),
    );
  }

  static bool _hasSaladOrHealthyMeal(List<DayPlan> weekPlan) {
    return weekPlan.any(
      (day) => day.meals.any(
        (meal) => meal.tags.any((tag) {
          final lower = tag.toLowerCase();
          return lower.contains('salad') || lower.contains('healthy');
        }),
      ),
    );
  }

  /// Achievement cards; titles use [easy_localization] `.tr()`.
  static List<(String, String, String, bool)> _buildAchievements(
    List<DayPlan> weekPlan,
    WeekProgressStats stats,
  ) {
    return [
      (
        '🔥',
        'progress.achievement.streak7_title'.tr(),
        'progress.achievement.streak7_desc'.tr(),
        stats.streak >= 7,
      ),
      (
        '🥗',
        'progress.achievement.salad_title'.tr(),
        'progress.achievement.salad_desc'.tr(),
        _hasSaladOrHealthyMeal(weekPlan),
      ),
      // TODO: app chưa track nước
      (
        '💧',
        'progress.achievement.hydrated_title'.tr(),
        'progress.achievement.hydrated_desc'.tr(),
        false,
      ),
      // TODO: cần lịch sử nhiều tuần để chính xác
      (
        '🏆',
        'progress.achievement.goal_crusher_title'.tr(),
        'progress.achievement.goal_crusher_desc'.tr(),
        stats.mealsLogged >= 10,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

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
            // Title + shared app bar
            SliverToBoxAdapter(
              child: CustomAppBar(title: 'progress.title'.tr()),
            ),

            // Streak + stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
                child: Consumer<MealPlanProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const SizedBox(
                        height: 88,
                        child: CenteredLoading(),
                      );
                    }
                    final stats = _buildWeekStats(
                      provider.weekPlan,
                      provider.targetCalories,
                    );
                    return Row(
                      children: [
                        StatCardWidget(
                          emoji: '🔥',
                          value: '${stats.streak}',
                          label: 'progress.stat_day_streak'.tr(),
                          color: AppColors.primaryLight,
                        ),
                        AppGap.w10,
                        StatCardWidget(
                          emoji: '✅',
                          value: '${stats.mealsLogged}',
                          label: 'progress.stat_meals_logged'.tr(),
                          color: AppColors.successLight,
                        ),
                        AppGap.w10,
                        StatCardWidget(
                          emoji: '🎯',
                          value: '${stats.goalHitPercent}%',
                          label: 'progress.stat_goal_hit'.tr(),
                          color: AppColors.secondaryLight,
                        ),
                      ],
                    );
                  },
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
                    Consumer<MealPlanProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const SizedBox(
                            height: 150,
                            child: CenteredLoading(),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'progress.weekly_goal'.tr(
                                namedArgs: {
                                  'kcal': provider.targetCalories.toString(),
                                },
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            AppGap.h20,
                            WeeklyBarChartWidget(
                              data: _weeklyCaloriesFromWeekPlan(
                                provider.weekPlan,
                              ),
                              days: weekDays,
                              goal: provider.targetCalories,
                            ),
                          ],
                        );
                      },
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
                    Consumer<MealPlanProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const SizedBox(
                            height: 120,
                            child: CenteredLoading(),
                          );
                        }
                        final macros = _buildNutritionConsistency(
                          provider.weekPlan,
                          targetProtein: provider.targetProtein,
                          targetCarbs: provider.targetCarbs,
                          targetFat: provider.targetFat,
                        );
                        return Column(
                          children: [
                            NutritionConsistencyRowWidget(
                              label: 'progress.nutrition_protein'.tr(),
                              percent: macros.proteinPercent,
                              color: AppColors.secondary,
                            ),
                            AppGap.h10,
                            NutritionConsistencyRowWidget(
                              label: 'progress.nutrition_carbs'.tr(),
                              percent: macros.carbsPercent,
                              color: AppColors.accentDark,
                            ),
                            AppGap.h10,
                            NutritionConsistencyRowWidget(
                              label: 'progress.nutrition_fat'.tr(),
                              percent: macros.fatPercent,
                              color: AppColors.primary,
                            ),
                          ],
                        );
                      },
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
              sliver: Consumer<MealPlanProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: CenteredLoading(),
                      ),
                    );
                  }
                  final stats = _buildWeekStats(
                    provider.weekPlan,
                    provider.targetCalories,
                  );
                  final achievements = _buildAchievements(
                    provider.weekPlan,
                    stats,
                  );
                  return SliverGrid.count(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}