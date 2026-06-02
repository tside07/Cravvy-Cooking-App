import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumFeaturesCardWidget extends StatelessWidget {
  final List<String> features;

  const PremiumFeaturesCardWidget({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a20,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: AppColors.border.withValues(alpha: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 22)),
              AppGap.w8,
              Expanded(
                child: Text(
                  'premium.define'.tr(),
                  style: AppTextStyles.s16.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h16,

          // Feature rows
          ...features.map(
            (feature) => Padding(
              padding: AppPad.b12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  AppGap.w10,
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
