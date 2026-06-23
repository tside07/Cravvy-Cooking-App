import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class NoteBoxWidget extends StatelessWidget {
  const NoteBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.s14.copyWith(
      color: PreAuthTheme.textSecondary,
      height: 1.5,
    );
    return Container(
      padding: AppPad.a14,
      decoration: BoxDecoration(
        color: PreAuthTheme.surface,
        borderRadius: AppBorderRadius.a14,
        border: Border.all(color: PreAuthTheme.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          AppGap.w10,
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'auth.otp_note_prefix'.tr(),
                style: baseStyle,
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
                    style: baseStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
