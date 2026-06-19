import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_login_button.dart';

class AuthSocialSectionWidget extends StatelessWidget {
  const AuthSocialSectionWidget({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
    this.isEnabled = true,
  });

  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthSocialLoginButton(
          provider: SocialProvider.google,
          onTap: onGoogleTap,
          isEnabled: isEnabled,
        ),
        AppGap.h12,
        AuthSocialLoginButton(
          provider: SocialProvider.apple,
          onTap: onAppleTap,
          isEnabled: isEnabled,
        ),
      ],
    );
  }
}
