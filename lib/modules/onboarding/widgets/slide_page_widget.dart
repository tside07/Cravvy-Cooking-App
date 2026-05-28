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
    bgColor: AppColors.primaryLight,
    accentColor: AppColors.primary,
  ),
  OnboardingSlide(
    emoji: IconPath.calendar,
    title: 'Plan your\nweek effortlessly',
    subtitle:
        'Get a personalized 7-day meal plan based on your health goals, diet type, and cooking time.',
    bgColor: AppColors.secondaryLight,
    accentColor: AppColors.secondary,
  ),
  OnboardingSlide(
    emoji: IconPath.target,
    title: 'Track nutrition\nwith ease',
    subtitle:
        'Monitor calories, macros and streaks automatically — no manual logging required.',
    bgColor: AppColors.warningLight,
    accentColor: AppColors.accentDark,
  ),
];

class SlidePageWidget extends StatelessWidget {
  const SlidePageWidget({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;
        final circleSize = isCompact ? 172.0 : 200.0;
        final iconSize = isCompact ? 104.0 : 120.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: slide.accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    slide.emoji,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(
                      slide.accentColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 36 : 48),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.s20.copyWith(
                  fontSize: isCompact ? 24 : 28,
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
                  fontSize: isCompact ? 15 : 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
