import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

/// Shown under the week strip when the user only has a 3-day Free view.
class FreeWeekUpsellBanner extends StatelessWidget {
  const FreeWeekUpsellBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        if (provider.hasPremiumAccess) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => context.push(AppRouter.subscription),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 18)),
                    AppGap.w10,
                    Expanded(
                      child: Text(
                        'limits.free_week_hint'.tr(),
                        style: AppTextStyles.s12.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppGap.w8,
                    Text(
                      'limits.upgrade'.tr(),
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
