import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class BackToLoginWidget extends StatelessWidget {
  const BackToLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'auth.back_to_login'.tr(),
        style: context.themed(
          AppTextStyles.s14,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
