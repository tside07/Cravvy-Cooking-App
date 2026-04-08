import 'package:cravvy_cooking_app/init.dart';

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
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: 'Resend code in ',
            style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: secondsLeft > 0 ? countdownLabel : 'Resend',
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (secondsLeft == 0)
          GestureDetector(
            onTap: onResend,
            child: Padding(
              padding: AppPad.t5,
              child: Text(
                'Tap to resend',
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
