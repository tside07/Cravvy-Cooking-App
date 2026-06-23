import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpTextWidget extends StatelessWidget {
  const HelpTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'auth.otp_help_text'.tr(),
      style: AppTextStyles.s12.copyWith(
        color: PreAuthTheme.textDisabled,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
