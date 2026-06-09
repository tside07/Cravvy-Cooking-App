import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

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
          text: 'auth.otp_note_prefix'.tr(),
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ).copyWith(height: 1.5),
          children: [
            TextSpan(
              text: 'auth.otp_valid_duration'.tr(),
              style: AppTextStyles.s14.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'auth.otp_note_suffix'.tr(),
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
