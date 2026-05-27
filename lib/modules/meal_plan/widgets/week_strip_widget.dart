import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

class WeekStripWidget extends StatelessWidget {
  const WeekStripWidget({super.key});

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final weekStart = _currentWeekStart();
        final visible = provider.visibleDayIndices;
        final showPremiumTeaser =
            !provider.hasPremiumAccess && visible.length < 7;

        return Container(
          height: 90,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  onTap: () => context.push(AppRouter.premium),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: AppPad.v10,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppBorderRadius.a16,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.border,
              width: isToday && !isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WeekStripWidget._days[index],
                style: AppTextStyles.s12.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
              AppGap.h4,
              Text(
                DateFormat('d').format(date),
                style: AppTextStyles.s16.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              AppGap.h6,
              Container(
                width: 6,
                height: 6,
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
                                  : AppColors.border,
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: AppPad.v10,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.a16,
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
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              AppGap.h4,
              Text(
                '+$hiddenCount',
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h2,
              Text(
                'limits.unlock_week'.tr(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s10.copyWith(
                  color: AppColors.textSecondary,
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
