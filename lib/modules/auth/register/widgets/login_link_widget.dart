import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class LoginLinkWidget extends StatelessWidget {
  const LoginLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: AppTextStyles.s14.copyWith(
            color: PreAuthTheme.textSecondary,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  'Sign In',
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
