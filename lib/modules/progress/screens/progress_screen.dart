import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/utils/meal_plan_streak.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton_layouts.dart';
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

    final streak = MealPlanStreak.days(weekPlan, todayIndex: todayIndex);

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
  static List<(IconData, String, String, bool)> _buildAchievements(
    List<DayPlan> weekPlan,
    WeekProgressStats stats,
  ) {
    return [
      (
        Icons.local_fire_department_rounded,
        'progress.achievement.streak7_title'.tr(),
        'progress.achievement.streak7_desc'.tr(),
        stats.streak >= 7,
      ),
      (
        Icons.eco_rounded,
        'progress.achievement.salad_title'.tr(),
        'progress.achievement.salad_desc'.tr(),
        _hasSaladOrHealthyMeal(weekPlan),
      ),
      // TODO: app chưa track nước
      (
        Icons.water_drop_rounded,
        'progress.achievement.hydrated_title'.tr(),
        'progress.achievement.hydrated_desc'.tr(),
        false,
      ),
      // TODO: cần lịch sử nhiều tuần để chính xác
      (
        Icons.emoji_events_rounded,
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
                padding: AppPad.section16t20,
                child: Consumer<MealPlanProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Row(
                        children: const [
                          StatCardSkeleton(),
                          AppGap.w10,
                          StatCardSkeleton(),
                          AppGap.w10,
                          StatCardSkeleton(),
                        ],
                      );
                    }
                    final stats = _buildWeekStats(
                      provider.weekPlan,
                      provider.targetCalories,
                    );
                    return Row(
                      children: [
                        StatCardWidget(
                          icon: Icons.local_fire_department_rounded,
                          value: '${stats.streak}',
                          label: 'progress.stat_day_streak'.tr(),
                          color: AppColors.primaryLight,
                        ),
                        AppGap.w10,
                        StatCardWidget(
                          icon: Icons.check_circle_rounded,
                          value: '${stats.mealsLogged}',
                          label: 'progress.stat_meals_logged'.tr(),
                          color: AppColors.successLight,
                        ),
                        AppGap.w10,
                        StatCardWidget(
                          icon: Icons.adjust_rounded,
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
                margin: AppPad.section16t16,
                padding: AppPad.a20,
                decoration: context.cardBox(radius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'progress.weekly_calories'.tr(),
                      style: context.themed(AppTextStyles.h2),
                    ),
                    AppGap.h4,
                    Consumer<MealPlanProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const _WeeklyChartSkeleton();
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
                margin: AppPad.section16t14,
                padding: AppPad.a20,
                decoration: context.cardBox(radius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'progress.nutrition_consistency'.tr(),
                      style: context.themed(AppTextStyles.h2),
                    ),
                    AppGap.h16,
                    Consumer<MealPlanProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const _ConsistencySkeleton();
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
                padding: AppPad.section24t20,
                child: Text(
                  'progress.achievements'.tr(),
                  style: context.themed(AppTextStyles.h2),
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
                    return SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.5,
                      children: const [
                        _AchievementCardSkeleton(),
                        _AchievementCardSkeleton(),
                        _AchievementCardSkeleton(),
                        _AchievementCardSkeleton(),
                      ],
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
                            icon: a.$1,
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

// ─── Skeleton loading sub-widgets ────────────────────────────────────────────

/// Weekly calorie bar chart placeholder: seven varied-height bars with day
/// labels under them.
class _WeeklyChartSkeleton extends StatelessWidget {
  const _WeeklyChartSkeleton();

  static const _heights = [60.0, 95.0, 50.0, 115.0, 78.0, 102.0, 68.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Skeleton(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final h in _heights)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SkeletonBox(
                        width: double.infinity,
                        height: h,
                        radius: 6,
                      ),
                      const SizedBox(height: 8),
                      const SkeletonBox(width: 16, height: 8, radius: 4),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Nutrition consistency placeholder: three label + progress-bar rows.
class _ConsistencySkeleton extends StatelessWidget {
  const _ConsistencySkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        children: const [
          _ConsistencyRowSkeleton(),
          AppGap.h10,
          _ConsistencyRowSkeleton(),
          AppGap.h10,
          _ConsistencyRowSkeleton(),
        ],
      ),
    );
  }
}

class _ConsistencyRowSkeleton extends StatelessWidget {
  const _ConsistencyRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SkeletonBox(width: 80, height: 10, radius: 4),
            SkeletonBox(width: 32, height: 10, radius: 4),
          ],
        ),
        AppGap.h8,
        const SkeletonBox(height: 8, radius: 4),
      ],
    );
  }
}

/// Achievement card placeholder: icon badge + two text lines.
class _AchievementCardSkeleton extends StatelessWidget {
  const _AchievementCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a12,
      decoration: context.cardBox(radius: 16),
      child: Skeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SkeletonCircle(size: 32),
            AppGap.h10,
            const SkeletonLine(widthFactor: 0.7, height: 10),
            AppGap.h6,
            const SkeletonLine(widthFactor: 0.95, height: 8),
          ],
        ),
      ),
    );
  }
}