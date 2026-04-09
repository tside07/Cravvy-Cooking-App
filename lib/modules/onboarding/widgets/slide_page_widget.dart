import 'package:cravvy_cooking_app/init.dart';

class OnboardingSlide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}

const kOnboardingSlides = [
  OnboardingSlide(
    emoji: IconPath.plate,
    title: 'What should\nI eat today?',
    subtitle:
        'Tell us what\'s in your fridge and we\'ll suggest delicious, healthy meals tailored just for you.',
    bgColor: Color(0xFFFFF3EE),
    accentColor: AppColors.primary,
  ),
  OnboardingSlide(
    emoji: IconPath.calendar,
    title: 'Plan your\nweek effortlessly',
    subtitle:
        'Get a personalized 7-day meal plan based on your health goals, diet type, and cooking time.',
    bgColor: Color(0xFFE8FAF8),
    accentColor: AppColors.secondary,
  ),
  OnboardingSlide(
    emoji: IconPath.target,
    title: 'Track nutrition\nwith ease',
    subtitle:
        'Monitor calories, macros and streaks automatically — no manual logging required.',
    bgColor: Color(0xFFFFFAE6),
    accentColor: AppColors.accentDark,
  ),
];

class SlidePageWidget extends StatelessWidget {
  const SlidePageWidget({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPad.h32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: slide.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                slide.emoji,
                width: 120,
                height: 120,
                colorFilter: ColorFilter.mode(
                  slide.accentColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          AppGap.h48,
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.s20.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          AppGap.h16,
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.s16.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
