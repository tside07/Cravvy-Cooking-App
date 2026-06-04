import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/resources/resources.dart';

enum SocialProvider { google, apple }

/// Social login button dùng cho cả Google và Apple.
class AuthSocialLoginButton extends StatelessWidget {
  const AuthSocialLoginButton({
    super.key,
    required this.provider,
    required this.onTap,
    this.isEnabled = true,
  });

  final SocialProvider provider;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider == SocialProvider.google;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isEnabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.a14,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (isGoogle)
              _GoogleIcon()
            else
            _AppleIcon(),
              // const Icon(Icons.apple, size: 22, color: AppColors.textPrimary),
            AppGap.w10,
            Text(
              isGoogle ? 'Continue with Google' : 'Continue with Apple',
              style: AppTextStyles.s16.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(IconPath.google, width: 20, height: 20),
    );
  }
}

class _AppleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(IconPath.apple, width: 20, height: 20),
    );
  }
}
