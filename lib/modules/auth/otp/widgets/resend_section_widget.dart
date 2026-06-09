import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ResendSectionWidget extends StatelessWidget {
  const ResendSectionWidget({
    super.key,
    required this.secondsLeft,
    required this.countdownLabel,
    required this.onResend,
  });

  final int secondsLeft;
  final String countdownLabel;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          secondsLeft > 0 ? 'auth.otp_resend_countdown_prefix'.tr() : '',
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: secondsLeft == 0 ? onResend : null,
          child: Text(
            secondsLeft > 0 ? countdownLabel : 'auth.otp_resend'.tr(),
            style: AppTextStyles.s14.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
