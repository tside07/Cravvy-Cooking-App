import 'package:cravvy_cooking_app/init.dart';

class NoteBoxWidget extends StatelessWidget {
  const NoteBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.a14,
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppBorderRadius.a14,
        border: Border.all(color: AppColors.warning),
      ),
      child: RichText(
        text: TextSpan(
          text: 'Note: The OTP code is valid for ',
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ).copyWith(height: 1.5),
          children: [
            TextSpan(
              text: '10 minutes',
              style: AppTextStyles.s14.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '. Please check your inbox and spam folder.',
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
