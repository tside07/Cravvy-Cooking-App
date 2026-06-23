import 'package:cravvy_cooking_app/core/theme/app_input_decoration.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/password_rule_widget.dart';
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: AppBorderRadius.a18,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  AppGap.h20,
                  Text(
                    'auth.reset_title'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(
                      color: PreAuthTheme.textPrimary,
                      fontSize: 26,
                      letterSpacing: -0.4,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'auth.reset_subtitle'.tr(namedArgs: {'email': email}),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.s15.copyWith(
                      color: PreAuthTheme.textSecondary,
                      height: 1.5,
                    ),
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
              decoration: AppInputDecoration.preAuthSoft(
                hint: 'auth.hint_new_password'.tr(),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: PreAuthTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: PreAuthTheme.textSecondary,
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
                      borderRadius: const BorderRadius.all(AppRadius.c4),
                      child: LinearProgressIndicator(
                        value: strengthPct,
                        backgroundColor: PreAuthTheme.surface,
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
              decoration: AppInputDecoration.preAuthSoft(
                hint: 'auth.hint_confirm_password'.tr(),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: PreAuthTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: onToggleConfirm,
                  child: Icon(
                    showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: PreAuthTheme.textSecondary,
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
                    borderRadius: AppBorderRadius.button,
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
