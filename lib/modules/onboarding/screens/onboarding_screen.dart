import 'package:cravvy_cooking_app/init.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/slide_page_widget.dart';

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
    if (_currentPage < kOnboardingSlides.length - 1) {
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
    final slide = kOnboardingSlides[_currentPage];
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

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: kOnboardingSlides.length,
                itemBuilder: (context, i) =>
                    SlidePageWidget(slide: kOnboardingSlides[i]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: kOnboardingSlides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: slide.accentColor,
                      dotColor: slide.accentColor.withValues(alpha: 0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  AppGap.h28,
                  CravvyButton(
                    label: _currentPage < kOnboardingSlides.length - 1
                        ? 'Continue'
                        : 'Get Started',
                    onTap: _next,
                    backgroundColor: slide.accentColor,
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
