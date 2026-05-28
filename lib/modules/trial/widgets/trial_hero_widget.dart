import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class TrialHeroWidget extends StatelessWidget {
  const TrialHeroWidget({
    super.key,
    required this.scaleAnim,
    required this.fadeAnim,
  });

  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated icon
        ScaleTransition(
          scale: scaleAnim,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        AppGap.h28,

        FadeTransition(
          opacity: fadeAnim,
          child: Column(
            children: [
              Text(
                'trial.started'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.s20.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              AppGap.h12,
              Text(
                'trial.welcome'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
