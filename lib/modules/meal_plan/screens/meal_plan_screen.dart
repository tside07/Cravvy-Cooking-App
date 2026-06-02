// lib/modules/meal_plan/screens/meal_plan_screen.dart

import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/services/usage_limit_service.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/free_week_upsell_banner.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/week_strip_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/calorie_summary_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_card_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/screens/add_meal_sheet.dart';
import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'meal_plan.title'.tr(),
              subtitle: 'meal_plan.subtitle'.tr(),
              trailing: const _StreakBadge(),
            ),
            const WeekStripWidget(),
            const FreeWeekUpsellBanner(),
            const CalorieSummaryWidget(),
            const Expanded(child: _MealList()),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.h12v6,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppBorderRadius.a20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: AppTextStyles.s14),
          AppGap.w4,
          Text(
            'meal_plan.streak_days'.tr(namedArgs: {'n': '7'}),
            style: AppTextStyles.s12.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealList extends StatelessWidget {
  const _MealList();

  static const _allSlots = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'meal_plan.loading'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.status == MealPlanStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 36)),
                AppGap.h12,
                Text(
                  'meal_plan.load_error'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppGap.h12,
                TextButton(
                  onPressed: provider.reload,
                  child: Text(
                    'meal_plan.retry'.tr(),
                    style: AppTextStyles.s14.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }

        final day = provider.selectedDay;
        final meals = day.meals;

        return RefreshIndicator(
          onRefresh: provider.reload,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _allSlots.length + 1, // +1 cho banner
            itemBuilder: (context, i) {
              // Index 0: banner "Làm mới gợi ý"
              if (i == 0) {
                return _RefreshSuggestionBanner(
                  cooldownSeconds: provider.refreshCooldownSeconds,
                  weeklyExhausted: provider.isWeeklyRefreshExhausted,
                  canRefresh: provider.canTapRefresh,
                  onRefresh: () => _confirmRefresh(context, provider),
                );
              }

              final slotType = _allSlots[i - 1];
              final match = meals.where((m) => m.type == slotType).toList();

              if (match.isNotEmpty) {
                final meal = match.first;
                return MealCardWidget(
                  meal: meal,
                  onToggle: () => provider.toggleMealLogged(meal.id),
                  onSwap: () => _showSwapSheet(context, provider, meal),
                  onRemove: () => provider.removeMeal(
                    date: day.date,
                    mealType: _typeStr(slotType),
                  ),
                );
              }

              return EmptyMealSlotCard(
                mealType: slotType,
                onAdd: () => _showAddSheet(context, day.date, slotType),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmRefresh(
    BuildContext context,
    MealPlanProvider provider,
  ) async {
    final blockReason = await provider.forceRefreshBlockReason();
    if (!context.mounted) return;
    if (blockReason != AiRefreshBlockReason.none) {
      final String message;
      if (blockReason == AiRefreshBlockReason.cooldown) {
        final sec = await provider.forceRefreshCooldownSecondsRemaining();
        message = 'meal_plan.refresh_cooldown_banner'.tr(
          namedArgs: {
            'time': MealPlanProvider.formatCooldown(
              sec > 0 ? sec : provider.refreshCooldownSeconds,
            ),
          },
        );
      } else {
        message = 'limits.ai_refresh_exhausted'.tr();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'meal_plan.refresh_dialog_title'.tr(),
          style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'meal_plan.refresh_dialog_body'.tr(),
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.cancel'.tr(),
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await provider.autoFillWeek(forceRefresh: true);
              if (!context.mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'meal_plan.refresh_success_cooldown'.tr(
                        namedArgs: {
                          'minutes':
                              '${PlanLimits.aiRefreshCooldownMinutes}',
                        },
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: Text(
              'meal_plan.refresh'.tr(),
              style: AppTextStyles.s14.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, DateTime date, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<MealPlanProvider>()),
          ChangeNotifierProvider.value(value: context.read<RecipeProvider>()),
        ],
        child: AddMealSheet(date: date, mealType: mealType),
      ),
    );
  }

  void _showSwapSheet(
    BuildContext context,
    MealPlanProvider provider,
    Meal meal,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: context.read<RecipeProvider>()),
        ],
        child: MealSwapSheet(meal: meal),
      ),
    );
  }

  String _typeStr(MealType t) {
    switch (t) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
      case MealType.snack:
        return 'snack';
    }
  }
}

class _RefreshSuggestionBanner extends StatelessWidget {
  const _RefreshSuggestionBanner({
    required this.cooldownSeconds,
    required this.weeklyExhausted,
    required this.canRefresh,
    required this.onRefresh,
  });

  final int cooldownSeconds;
  final bool weeklyExhausted;
  final bool canRefresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final onCooldown = cooldownSeconds > 0;
    final countdown = MealPlanProvider.formatCooldown(cooldownSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: onCooldown
            ? AppColors.surface
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onCooldown
              ? AppColors.textSecondary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Text(onCooldown ? '⏳' : '✨', style: const TextStyle(fontSize: 14)),
          AppGap.w8,
          Expanded(
            child: Text(
              onCooldown
                  ? 'meal_plan.refresh_cooldown_banner'.tr(
                      namedArgs: {'time': countdown},
                    )
                  : weeklyExhausted
                  ? 'meal_plan.refresh_weekly_exhausted'.tr()
                  : 'meal_plan.banner_hint'.tr(),
              style: AppTextStyles.s12.copyWith(
                color: onCooldown
                    ? AppColors.textSecondary
                    : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGap.w8,
          if (onCooldown)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                countdown,
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: canRefresh ? onRefresh : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: canRefresh
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  weeklyExhausted
                      ? 'meal_plan.refresh'.tr()
                      : 'meal_plan.refresh'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
