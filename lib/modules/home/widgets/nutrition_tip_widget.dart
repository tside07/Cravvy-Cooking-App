import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class NutritionTipWidget extends StatelessWidget {
  const NutritionTipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        top: 24,
        right: 16,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: AppBorderRadius.a18,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('💡', style: AppTextStyles.s20),
            ),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.tip_title'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark,
                  ),
                ),
                AppGap.h3,
                Text(
                  'home.tip_body'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
