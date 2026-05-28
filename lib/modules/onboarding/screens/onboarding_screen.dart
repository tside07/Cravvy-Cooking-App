import 'package:cravvy_cooking_app/init.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = kOnboardingSlides[_currentPage];
    return Scaffold(
      backgroundColor: slide.bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 768 ? 32.0 : 24.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go(AppRouter.goalSelection),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.s16.copyWith(
                            color: slide.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: kOnboardingSlides.length,
                        itemBuilder: (context, i) =>
                            SlidePageWidget(slide: kOnboardingSlides[i]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        32,
                      ),
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
          },
        ),
      ),
    );
  }
}
