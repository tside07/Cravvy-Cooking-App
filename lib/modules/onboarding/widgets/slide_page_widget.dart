import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
class OnboardingSlide {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

List<OnboardingSlide> kOnboardingSlides(BuildContext context) => [
  OnboardingSlide(
    imagePath: ImagePath.onboarding1,
    title: 'onboarding_slide.sl1_title'.tr(),
    subtitle: 'onboarding_slide.sl1_subtitle'.tr(),
  ),
  OnboardingSlide(
    imagePath: ImagePath.onboarding2,
    title: 'onboarding_slide.sl2_title'.tr(),
    subtitle: 'onboarding_slide.sl2_subtitle'.tr(),
  ),
  OnboardingSlide(
    imagePath: ImagePath.onboarding3,
    title: 'onboarding_slide.sl3_title'.tr(),
    subtitle: 'onboarding_slide.sl3_subtitle'.tr(),
  ),
];
class SlidePageWidget extends StatelessWidget {
  const SlidePageWidget({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 55,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: AppBorderRadius.a16,
              child: Image.asset(
                slide.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // ── Text phía dưới, left-aligned ──
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: AppTextStyles.s20.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PreAuthTheme.textPrimary,
                    fontSize: 32,
                    height: 1.15,
                  ),
                ),
                AppGap.h12,
                Text(
                  slide.subtitle,
                  style: AppTextStyles.s16.copyWith(
                    color: PreAuthTheme.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
