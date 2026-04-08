import 'package:cravvy_cooking_app/init.dart';

class RegisterLinkWidget extends StatelessWidget {
  const RegisterLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.register),
                child: Text(
                  'Sign Up',
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
