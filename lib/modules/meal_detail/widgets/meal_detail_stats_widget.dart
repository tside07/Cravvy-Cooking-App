import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:easy_localization/easy_localization.dart';

/// Four-column stat strip: Prep time, Calories, Servings, Difficulty level.
class MealDetailStatsWidget extends StatelessWidget {
  const MealDetailStatsWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppPad.h16v20,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final items = [
              _StatItem(
                icon: Icons.timer_outlined,
                iconColor: AppColors.primary,
                value: '${meal.prepTime}${'meal_plan.minutes_short'.tr()}',
                label: 'meal_detail.stat_prep'.tr(),
              ),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.warning,
                value: '${meal.calories}',
                label: 'meal_detail.stat_cal'.tr(),
              ),
              _StatItem(
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.secondary,
                value: '2',
                label: 'meal_detail.stat_servings'.tr(),
              ),
              _StatItem(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.secondaryDark,
                value: 'meal_detail.level_medium'.tr(),
                label: 'meal_detail.stat_level'.tr(),
              ),
            ];

            if (constraints.maxWidth < 420) {
              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (_, i) => items[i],
              );
            }

            return Row(
              children: [
                Expanded(child: items[0]),
                _divider,
                Expanded(child: items[1]),
                _divider,
                Expanded(child: items[2]),
                _divider,
                Expanded(child: items[3]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget get _divider => Container(
        width: 1,
        height: 36,
        margin: AppPad.h16,
        color: AppColors.border,
      );
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        AppGap.h6,
        Text(
          label,
          style: AppTextStyles.s10.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppGap.h2,
        Text(
          value,
          style: AppTextStyles.s14.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
