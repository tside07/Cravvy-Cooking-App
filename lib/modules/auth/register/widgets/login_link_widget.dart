import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginLinkWidget extends StatelessWidget {
  const LoginLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '${'auth.have_account_prefix'.tr()} ',
          style: AppTextStyles.s14.copyWith(
            color: PreAuthTheme.textSecondary,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  'auth.sign_in_link'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
