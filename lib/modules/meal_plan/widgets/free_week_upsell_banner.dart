import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shown under week strip for Free users.
class FreeWeekUpsellBanner extends StatelessWidget {
  const FreeWeekUpsellBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push(AppRouter.premium),
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
  }
}
