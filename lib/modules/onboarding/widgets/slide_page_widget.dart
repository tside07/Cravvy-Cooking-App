import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

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

const kOnboardingSlides = [
  OnboardingSlide(
    imagePath: ImagePath.onboarding1,
    title: 'What should\nI eat today?',
    subtitle:
        'Tell us what\'s in your fridge and we\'ll suggest delicious, healthy meals tailored just for you.',
  ),
  OnboardingSlide(
    imagePath: ImagePath.onboarding2,
    title: 'Plan your\nweek effortlessly',
    subtitle:
        'Get a personalized 7-day meal plan based on your health goals, diet type, and cooking time.',
  ),
  OnboardingSlide(
    imagePath: ImagePath.onboarding3,
    title: 'Track nutrition\nwith ease',
    subtitle:
        'Monitor calories, macros and streaks automatically — no manual logging required.',
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
              borderRadius: BorderRadius.circular(20),
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
