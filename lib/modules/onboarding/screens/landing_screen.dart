import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/welcome_choice_screen.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:easy_localization/easy_localization.dart';

/// Lifesum-style pre-auth entry: full-bleed photo, bottom scrim, CTA stack.
/// CREATE ACCOUNT → onboarding slides; LOG IN → auth hub (login mode).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _lifesumGreen = Color(0xFF57E35D);
  static const _heroAsset = ImagePath.landing;

  @override
  Widget build(BuildContext context) {
    return PreAuthScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LandingHero(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x33000000),
                  Color(0x99000000),
                  Color(0xE6000000),
                ],
                stops: [0.25, 0.5, 0.72, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth >= 768 ? 40.0 : 24.0;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: _LandingBrandMark()),
                      const Spacer(),
                      Text(
                        'landing.title'.tr(),
                        style: AppTextStyles.s20.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      AppGap.h12,
                      Text(
                        'landing.subtitle'.tr(),
                        style: AppTextStyles.s15.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.45,
                        ),
                      ),
                      AppGap.h28,
                      _LandingPrimaryButton(
                        label: 'landing.create_account'.tr(),
                        onTap: () => context.go(AppRouter.onboarding),
                      ),
                      AppGap.h12,
                      _LandingOutlineButton(
                        label: 'landing.log_in'.tr(),
                        onTap: () => context.go(
                          AppRouter.welcomeChoice,
                          extra: WelcomeMode.login,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingBrandMark extends StatelessWidget {
  const _LandingBrandMark();

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      child: Image.asset(
        ImagePath.appName,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(
          'Cravvy',
          style: AppTextStyles.s20.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero();

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();

    return Image.asset(
      LandingScreen._heroAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: cacheWidth > 0 ? cacheWidth : null,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A3D45),
              Color(0xFF1B262C),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 72,
            color: Color(0x33FFFFFF),
          ),
        ),
      ),
    );
  }
}

class _LandingPrimaryButton extends StatelessWidget {
  const _LandingPrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: LandingScreen._lifesumGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LandingOutlineButton extends StatelessWidget {
  const _LandingOutlineButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.white, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
