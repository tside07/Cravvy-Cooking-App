import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class TrialUnlockedCardWidget extends StatelessWidget {
  const TrialUnlockedCardWidget({super.key, required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPad.a20,
      decoration: context.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
              AppGap.w8,
              Text(
                'trial.unlocked'.tr(),
                style: context.themed(
                  AppTextStyles.s14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppGap.h14,

          // Feature list
          ...features.map(
            (f) => Padding(
              padding: AppPad.b10,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 13,
                    ),
                  ),
                  AppGap.w10,
                  Expanded(child: Text(f, style: context.themed(AppTextStyles.s14))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
