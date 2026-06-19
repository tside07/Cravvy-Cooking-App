import 'dart:async';

import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/welcome_choice_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/slide_page_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _autoAdvanceDelay = Duration(seconds: 5);
  static const _slideTransition = Duration(milliseconds: 400);

  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  /// Once the user swipes manually, auto-advance is disabled so we never
  /// pull them forward while they're still reading.
  bool _userTookControl = false;

  static const _slideCount = 3;

  bool get _isLastPage => _currentPage >= _slideCount - 1;

  @override
  void initState() {
    super.initState();
    _scheduleAutoAdvance();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Auto-advance one slide after [_autoAdvanceDelay] of inactivity.
  /// Restarted on every page change; stops at the last slide or once the
  /// user takes control by swiping.
  void _scheduleAutoAdvance() {
    _autoTimer?.cancel();
    if (_isLastPage || _userTookControl) return;
    _autoTimer = Timer(_autoAdvanceDelay, () {
      if (!mounted || _isLastPage || _userTookControl) return;
      _pageController.nextPage(
        duration: _slideTransition,
        curve: Curves.easeInOut,
      );
    });
  }

  /// Any manual touch hands control to the user and stops auto-advancing.
  void _onUserInteraction() {
    if (_userTookControl) return;
    _userTookControl = true;
    _autoTimer?.cancel();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _scheduleAutoAdvance();
  }

  void _finish() {
    _autoTimer?.cancel();
    context.go(AppRouter.welcomeChoice, extra: WelcomeMode.signup);
  }

  @override
  Widget build(BuildContext context) {
    final slides = kOnboardingSlides(context);
    return PreAuthScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const PreAuthBackButton(fallbackRoute: AppRouter.landing),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 768 ? 32.0 : 24.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    Expanded(
                      child: Listener(
                        onPointerDown: (_) => _onUserInteraction(),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: slides.length,
                          itemBuilder: (context, i) =>
                              SlidePageWidget(slide: slides[i]),
                        ),
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
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: slides.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: Colors.white,
                                dotColor: Colors.white24,
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                              ),
                            ),
                          ),
                          AppGap.h28,
                          // Button only on the last slide; reserve its height
                          // on earlier slides so the indicator stays put.
                          SizedBox(
                            height: 56,
                            child: _isLastPage
                                ? CravvyButton(
                                    label: 'onboarding.get_started'.tr(),
                                    onTap: _finish,
                                  )
                                : null,
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
