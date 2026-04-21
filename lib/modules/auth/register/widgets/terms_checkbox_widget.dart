import 'package:cravvy_cooking_app/init.dart';

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
              text: 'I agree to the ',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.push(AppRouter.termsOfService),
                    child: Text(
                      'Terms of Service',
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.push(AppRouter.privacyPolicy),
                    child: Text(
                      'Privacy Policy',
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
