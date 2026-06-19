import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterLinkWidget extends StatelessWidget {
  const RegisterLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '${'auth.no_account_prefix'.tr()} ',
          style: AppTextStyles.s14.copyWith(
            color: PreAuthTheme.textSecondary,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.register),
                child: Text(
                  'auth.sign_up_link'.tr(),
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
