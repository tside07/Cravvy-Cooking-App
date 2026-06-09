import 'package:cravvy_cooking_app/core/theme/app_input_decoration.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/password_rule_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPasswordFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String email;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool showPassword;
  final bool showConfirm;
  final bool isLoading;
  final double strengthPct;
  final Color strengthColor;
  final String strengthLabel;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  const ResetPasswordFormWidget({
    super.key,
    required this.formKey,
    required this.email,
    required this.passwordController,
    required this.confirmController,
    required this.showPassword,
    required this.showConfirm,
    required this.isLoading,
    required this.strengthPct,
    required this.strengthColor,
    required this.strengthLabel,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onPasswordChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final inputStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: PreAuthTheme.textPrimary);

    return Form(
      key: formKey,
      child: Padding(
        padding: AppPad.h24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGap.h8,
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  AppGap.h20,
                  AuthHeaderWidget(
                    title: 'auth.reset_title'.tr(),
                    subtitle: 'auth.reset_subtitle'.tr(
                      namedArgs: {'email': email},
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            AppGap.h32,

            // Password field
            TextFormField(
              controller: passwordController,
              obscureText: !showPassword,
              onChanged: onPasswordChanged,
              style: inputStyle,
              decoration: AppInputDecoration.underline.copyWith(
                labelText: 'auth.hint_new_password'.tr(),
                labelStyle: AppTextStyles.s16.copyWith(
                  color: PreAuthTheme.textSecondary,
                ),
                floatingLabelStyle: AppTextStyles.s13.copyWith(
                  color: PreAuthTheme.textPrimary,
                ),
                errorStyle: AppTextStyles.s12.copyWith(color: AppColors.error),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: appColors.iconInactive,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: appColors.iconInactive,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'auth.val_password_required'.tr();
                }
                if (v.length < 8) return 'auth.val_password_min_8'.tr();
                return null;
              },
            ),

            // Strength bar
            if (passwordController.text.isNotEmpty) ...[
              AppGap.h10,
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: strengthPct,
                        backgroundColor: appColors.elevated,
                        color: strengthColor,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    strengthLabel,
                    style: AppTextStyles.s12.copyWith(
                      color: strengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppGap.h4,
              PasswordRuleWidget(
                label: 'auth.password_rule_min_8'.tr(),
                met: passwordController.text.length >= 8,
              ),
              PasswordRuleWidget(
                label: 'auth.password_rule_uppercase'.tr(),
                met: RegExp(r'[A-Z]').hasMatch(passwordController.text),
              ),
              PasswordRuleWidget(
                label: 'auth.password_rule_number'.tr(),
                met: RegExp(r'\d').hasMatch(passwordController.text),
              ),
            ],

            AppGap.h20,

            // Confirm field
            TextFormField(
              controller: confirmController,
              obscureText: !showConfirm,
              style: inputStyle,
              decoration: AppInputDecoration.underline.copyWith(
                labelText: 'auth.hint_confirm_password'.tr(),
                labelStyle: AppTextStyles.s16.copyWith(
                  color: PreAuthTheme.textSecondary,
                ),
                floatingLabelStyle: AppTextStyles.s13.copyWith(
                  color: PreAuthTheme.textPrimary,
                ),
                errorStyle: AppTextStyles.s12.copyWith(color: AppColors.error),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: appColors.iconInactive,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: onToggleConfirm,
                  child: Icon(
                    showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: appColors.iconInactive,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'auth.val_confirm_required'.tr();
                }
                if (v != passwordController.text) {
                  return 'auth.val_password_mismatch'.tr();
                }
                return null;
              },
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'auth.reset_button'.tr(),
                        style: AppTextStyles.s16.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            AppGap.h24,
          ],
        ),
      ),
    );
  }
}
