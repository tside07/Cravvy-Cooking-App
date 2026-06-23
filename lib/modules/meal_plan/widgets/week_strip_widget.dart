import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

class WeekStripWidget extends StatelessWidget {
  const WeekStripWidget({super.key});

  static const _dayKeys = [
    'meal_plan.day_mon',
    'meal_plan.day_tue',
    'meal_plan.day_wed',
    'meal_plan.day_thu',
    'meal_plan.day_fri',
    'meal_plan.day_sat',
    'meal_plan.day_sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final weekStart = _currentWeekStart();
        final visible = provider.visibleDayIndices;
        final showPremiumTeaser =
            !provider.hasPremiumAccess && visible.length < 7;

        return Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              ...visible.map((i) => _DayCell(
                    index: i,
                    weekStart: weekStart,
                    provider: provider,
                  )),
              if (showPremiumTeaser)
                _LockedDaysTeaser(
                  hiddenCount: 7 - visible.length,
                  onTap: () => context.push(AppRouter.subscription),
                ),
            ],
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.index,
    required this.weekStart,
    required this.provider,
  });

  final int index;
  final DateTime weekStart;
  final MealPlanProvider provider;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final date = weekStart.add(Duration(days: index));
    final isSelected = provider.selectedDayIndex == index;
    final isToday = index == DateTime.now().weekday - 1;
    final hasPlan = provider.weekPlan.length == 7;
    final plan = hasPlan ? provider.weekPlan[index] : null;
    final hasAll = plan?.isComplete ?? false;
    final hasSome = (plan?.loggedCount ?? 0) > 0;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.selectDay(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: AppPad.v6,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : appColors.cardSurface,
            borderRadius: AppBorderRadius.a12,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : appColors.borderDivider,
              width: isToday && !isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WeekStripWidget._dayKeys[index].tr(),
                style: AppTextStyles.s12.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : appColors.textSecondary,
                ),
              ),
              AppGap.h2,
              Text(
                DateFormat('d').format(date),
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? appColors.onPrimary : appColors.textPrimary,
                ),
              ),
              AppGap.h3,
              Container(
                width: 5,
                height: 5,
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
                                  : appColors.borderDivider,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedDaysTeaser extends StatelessWidget {
  const _LockedDaysTeaser({
    required this.hiddenCount,
    required this.onTap,
  });

  final int hiddenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: AppPad.v6,
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: AppBorderRadius.a12,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              AppGap.h2,
              Text(
                '+$hiddenCount',
                style: AppTextStyles.s12.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'limits.unlock_week'.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s10.copyWith(
                  color: appColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
