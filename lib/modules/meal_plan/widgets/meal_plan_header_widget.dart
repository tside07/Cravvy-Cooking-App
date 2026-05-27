import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class MealPlanHeaderWidget extends StatelessWidget {
  const MealPlanHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        top: 16,
        right: 24,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'meal_plan.title'.tr(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                'meal_plan.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: AppPad.h12v6,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppBorderRadius.a20,
            ),
            child: Row(
              children: [
                const Text('🔥', style: AppTextStyles.s14),
                AppGap.w4,
                Text(
                  'meal_plan.streak_days'.tr(namedArgs: {'n': '7'}),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
