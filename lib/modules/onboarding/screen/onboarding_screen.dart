import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/cravvy_button.dart';

class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}

const _slides = [
  _Slide(
    emoji: '🍽️',
    title: 'What should\nI eat today?',
    subtitle: 'Tell us what's in your fridge and we\'ll suggest delicious, healthy meals tailored just for you.',
    bgColor: Color(0xFFFFF3EE),
    accentColor: AppColors.primary,
  ),
  _Slide(
    emoji: '📅',
    title: 'Plan your\nweek effortlessly',
    subtitle: 'Get a personalized 7-day meal plan based on your health goals, diet type, and cooking time.',
    bgColor: Color(0xFFE8FAF8),
    accentColor: AppColors.secondary,
  ),
  _Slide(
    emoji: '🎯',
    title: 'Track nutrition\nwith ease',
    subtitle: 'Monitor calories, macros and streaks automatically — no manual logging required.',
    bgColor: Color(0xFFFFFAE6),
    accentColor: AppColors.accentDark,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRouter.goalSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    return Scaffold(
      backgroundColor: slide.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRouter.goalSelection),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: slide.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlidePage(slide: _slides[i]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: slide.accentColor,
                      dotColor: slide.accentColor.withOpacity(0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CravvyButton(
                      label: _currentPage < _slides.length - 1
                          ? 'Continue'
                          : 'Get Started',
                      onTap: _next,
                      backgroundColor: slide.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: slide.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(slide.emoji, style: const TextStyle(fontSize: 90)),
            ),
          ),
          const SizedBox(height: 48),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
