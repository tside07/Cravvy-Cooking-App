import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/resources/resources.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final colors = context.appColors;
    final isGoogle = provider == SocialProvider.google;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isEnabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.cardSurface,
          side: BorderSide(color: colors.borderDivider),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
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
              isGoogle
                  ? 'auth.continue_google'.tr()
                  : 'auth.continue_apple'.tr(),
              style: context.themed(
                AppTextStyles.s16,
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
