import 'package:cravvy_cooking_app/init.dart';

class NutritionTipWidget extends StatelessWidget {
  const NutritionTipWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 22)),
            ),
          ),
          AppGap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: AppTextStyles.s12.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark,
                  ),
                ),
                AppGap.h3,
                Text(
                  'Drink water 30 min before meals to help with digestion and portion control.',
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
