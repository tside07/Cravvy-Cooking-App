import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:easy_localization/easy_localization.dart';

/// Nutrition tab content – macros breakdown cards.
class MealDetailNutritionWidget extends StatelessWidget {
  const MealDetailNutritionWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _MacroCard(
            label: 'meal_detail.stat_cal'.tr(),
            value: '${meal.calories}',
            unit: 'meal_plan.kcal_unit'.tr(),
            icon: Icons.local_fire_department_rounded,
            color: AppColors.warning,
            progress: (meal.calories / 2200).clamp(0.0, 1.0),
          ),
          AppGap.h12,
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: 'meal_plan.macro_protein'.tr(),
                  value: '${meal.protein}',
                  unit: 'g',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.secondary,
                  progress: (meal.protein / 150).clamp(0.0, 1.0),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: _MacroCard(
                  label: 'meal_plan.macro_carbs'.tr(),
                  value: '${meal.carbs}',
                  unit: 'g',
                  icon: Icons.grain_rounded,
                  color: AppColors.accentDark,
                  progress: (meal.carbs / 220).clamp(0.0, 1.0),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: _MacroCard(
                  label: 'meal_plan.macro_fat'.tr(),
                  value: '${meal.fat}',
                  unit: 'g',
                  icon: Icons.water_drop_rounded,
                  color: AppColors.primary,
                  progress: (meal.fat / 70).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          AppGap.h12,
          _NutritionNote(),
        ]),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: context.cardBox(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  label,
                  style: context.themed(
                    AppTextStyles.s12,
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h10,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: context.themed(
                    AppTextStyles.s20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: context.themed(
                    AppTextStyles.s12,
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AppGap.h8,
          ClipRRect(
            borderRadius: AppBorderRadius.a8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: AppBorderRadius.card,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          AppGap.w10,
          Expanded(
            child: Text(
              'meal_detail.nutrition_disclaimer'.tr(),
              style: AppTextStyles.s12.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
