import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/splash/widgets/loading_dot.dart';
import 'package:cravvy_cooking_app/resources/resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lắng nghe AuthProvider thay đổi
    final auth = Provider.of<AuthProvider>(context);
    _handleAuthState(auth);
  }

  void _handleAuthState(AuthProvider auth) {
    // Chưa resolve → chờ
    if (auth.status == AuthStatus.initial) return;
    // Đã redirect rồi → không làm gì nữa
    if (_redirected) return;
    // Đảm bảo animation xong ít nhất 1 lần rồi mới redirect
    final minWait = Future.delayed(const Duration(milliseconds: 1500));
    final animDone = _controller.isCompleted
        ? Future.value()
        : _controller.forward().orCancel.catchError((_) {});

    Future.wait([minWait, animDone]).then((_) {
      if (!mounted || _redirected) return;
      _redirected = true;

      if (auth.isLoggedIn) {
        // Đã login: check onboarding xong chưa
        if (auth.user?.onboardingComplete == true) {
          context.go(AppRouter.app);
        } else {
          // Chưa onboard xong → vào setup step 1
          context.go(AppRouter.setupStep1);
        }
      } else {
        // Chưa login → onboarding (lần đầu) hoặc login
        // Dùng onboarding làm entry point — user có thể skip vào login
        context.go(AppRouter.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightYellowBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Center(
                  child:
                      Image.asset(ImagePath.sticketLogo, width: 200, height: 200),
                ),
              ),
            ),
            AppGap.h20,
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Image.asset(ImagePath.appName, height: 65, width: 220),
                    AppGap.h8,
                    Text(
                      'Find your flavor',
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppGap.h80,
            FadeTransition(
              opacity: _textFade,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => LoadingDot(delay: i * 200)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}