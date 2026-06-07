import 'package:cravvy_cooking_app/init.dart';

class BackToLoginWidget extends StatelessWidget {
  const BackToLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Back to Login',
        style: context.themed(
          AppTextStyles.s14,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
