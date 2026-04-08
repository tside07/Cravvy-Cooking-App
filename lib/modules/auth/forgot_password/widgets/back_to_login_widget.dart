import 'package:cravvy_cooking_app/init.dart';

class BackToLoginWidget extends StatelessWidget {
  const BackToLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Back to Login',
        style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
