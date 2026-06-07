import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/screens/welcome_choice_screen.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:easy_localization/easy_localization.dart';

/// First screen shown before onboarding (Lifesum-style entry).
/// CREATE ACCOUNT → onboarding slides, LOG IN → auth hub (login mode).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PreAuthScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LandingHero(),
          // Bottom scrim so text/buttons stay readable over the photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                stops: [0.35, 0.6, 1.0],
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
                    0,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'landing.title'.tr(),
                        style: AppTextStyles.s20.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PreAuthTheme.textPrimary,
                          fontSize: 34,
                          height: 1.15,
                        ),
                      ),
                      AppGap.h12,
                      Text(
                        'landing.subtitle'.tr(),
                        style: AppTextStyles.s15.copyWith(
                          color: PreAuthTheme.textPrimary.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                      AppGap.h28,
                      CravvyButton(
                        label: 'landing.create_account'.tr(),
                        onTap: () => context.go(AppRouter.onboarding),
                      ),
                      AppGap.h12,
                      CravvyButton(
                        label: 'landing.log_in'.tr(),
                        isOutlined: true,
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

/// Placeholder for the full-bleed hero photo.
///
/// To use a real image, drop the asset into `assets/images/`, register it in
/// `pubspec.yaml`, and replace the body below with:
///   `Image.asset('assets/images/landing.jpg', fit: BoxFit.cover)`
class _LandingHero extends StatelessWidget {
  const _LandingHero();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF2A3A44),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.white24,
        ),
      ),
    );
  }
}
