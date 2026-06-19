import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpTextWidget extends StatelessWidget {
  const HelpTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      'auth.otp_help_text'.tr(),
      style: context.themed(
        AppTextStyles.s12,
        color: colors.textDisabled,
      ).copyWith(height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}
