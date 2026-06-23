import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_entry_button.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_sign_in_helper.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/oauth_loading_overlay.dart';
import 'package:cravvy_cooking_app/modules/legal/legal_docs.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_modal_sheet.dart';
import 'package:easy_localization/easy_localization.dart';

/// Which flow the auth hub belongs to. Controls copy + the email destination.
enum WelcomeMode { signup, login }

/// Auth hub: Apple, Google, or email. Reached from the landing screen (login)
/// or after onboarding (signup).
class WelcomeChoiceScreen extends StatefulWidget {
  const WelcomeChoiceScreen({super.key, this.mode = WelcomeMode.signup});

  final WelcomeMode mode;

  @override
  State<WelcomeChoiceScreen> createState() => _WelcomeChoiceScreenState();
}

class _WelcomeChoiceScreenState extends State<WelcomeChoiceScreen>
    with WidgetsBindingObserver {
  static const _resumeCancelDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isOAuthInProgress) return;

    // User returned from the browser — cancel if no session arrived yet.
    Future.delayed(_resumeCancelDelay, () {
      if (!mounted) return;
      if (!auth.isOAuthInProgress) return;
      if (SupabaseService.currentUser != null) return;
      auth.cancelOAuthSignIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isOAuthLoading = auth.isOAuthInProgress;
    final isLogin = widget.mode == WelcomeMode.login;

    return PreAuthScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PreAuthBackButton(
          fallbackRoute: isLogin ? AppRouter.landing : AppRouter.onboarding,
          onPressed: isOAuthLoading
              ? () => auth.cancelOAuthSignIn()
              : null,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth >= 768 ? 40.0 : 24.0;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      Text(
                        (isLogin ? 'welcome.login_title' : 'welcome.title').tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.s20.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PreAuthTheme.textPrimary,
                          fontSize: 28,
                          height: 1.25,
                        ),
                      ),
                      AppGap.h12,
                      Text(
                        (isLogin ? 'welcome.login_subtitle' : 'welcome.subtitle')
                            .tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.s15.copyWith(
                          color: PreAuthTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(flex: 3),
                      AuthEntryButton(
                        label: 'welcome.continue_apple'.tr(),
                        isEnabled: !isOAuthLoading,
                        leading: SvgPicture.asset(
                          IconPath.apple,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            PreAuthTheme.buttonText,
                            BlendMode.srcIn,
                          ),
                        ),
                        onTap: () => handleSocialSignIn(
                          context,
                          signIn: (a) => a.signInWithApple(),
                        ),
                      ),
                      AppGap.h12,
                      AuthEntryButton(
                        label: 'welcome.continue_google'.tr(),
                        isEnabled: !isOAuthLoading,
                        leading: SvgPicture.asset(
                          IconPath.google,
                          width: 22,
                          height: 22,
                        ),
                        onTap: () => handleSocialSignIn(
                          context,
                          signIn: (a) => a.signInWithGoogle(),
                        ),
                      ),
                      AppGap.h12,
                      AuthEntryButton(
                        label: 'welcome.continue_email'.tr(),
                        isEnabled: !isOAuthLoading,
                        leading: const Icon(
                          Icons.mail_outline_rounded,
                          size: 22,
                          color: PreAuthTheme.buttonText,
                        ),
                        onTap: () => context.push(
                          isLogin ? AppRouter.login : AppRouter.register,
                        ),
                      ),
                      AppGap.h24,
                      const _TermsFooter(),
                      AppGap.h16,
                    ],
                  ),
                );
              },
            ),
          ),
          if (isOAuthLoading)
            OAuthLoadingOverlay(
              onCancel: () => auth.cancelOAuthSignIn(),
            ),
        ],
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.s12.copyWith(
      color: PreAuthTheme.textSecondary,
      height: 1.5,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: '${'welcome.terms_prefix'.tr()} '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => showLegalSheet(context, LegalDoc.terms),
              child: Text('welcome.terms'.tr(), style: linkStyle),
            ),
          ),
          TextSpan(text: ' ${'welcome.terms_and'.tr()} '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => showLegalSheet(context, LegalDoc.privacy),
              child: Text('welcome.privacy'.tr(), style: linkStyle),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
