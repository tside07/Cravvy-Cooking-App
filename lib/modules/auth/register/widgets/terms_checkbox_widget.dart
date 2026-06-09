import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsCheckboxWidget extends StatelessWidget {
  const TermsCheckboxWidget({
    super.key,
    required this.agreedToTerms,
    required this.onChanged,
  });

  final bool agreedToTerms;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: agreedToTerms,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ),
        AppGap.w10,
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'auth.terms_prefix'.tr(),
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.push(AppRouter.termsOfService),
                    child: Text(
                      'auth.terms_link'.tr(),
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ' ${'auth.terms_and'.tr()} ',
                  style: context.themed(
                    AppTextStyles.s14,
                    color: colors.textSecondary,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.push(AppRouter.privacyPolicy),
                    child: Text(
                      'auth.privacy_link'.tr(),
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
