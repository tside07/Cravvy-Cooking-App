import 'package:cravvy_cooking_app/init.dart';

class HelpTextWidget extends StatelessWidget {
  const HelpTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      "Didn't receive the code? Check your spam folder or make sure the email address is correct.",
      style: context.themed(
        AppTextStyles.s12,
        color: colors.textDisabled,
      ).copyWith(height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}
