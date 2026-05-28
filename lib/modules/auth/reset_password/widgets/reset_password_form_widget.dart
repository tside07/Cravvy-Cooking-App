import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/password_rule_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';

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
                    title: 'Create New Password',
                    subtitle: 'Enter a strong password for $email',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            AppGap.h32,

            // Password field
            Text(
              'New Password',
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            TextFormField(
              controller: passwordController,
              obscureText: !showPassword,
              onChanged: onPasswordChanged,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'At least 8 characters';
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
                        backgroundColor: AppColors.surfaceVariant,
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
                label: 'At least 8 characters',
                met: passwordController.text.length >= 8,
              ),
              PasswordRuleWidget(
                label: 'Contains uppercase',
                met: RegExp(r'[A-Z]').hasMatch(passwordController.text),
              ),
              PasswordRuleWidget(
                label: 'Contains number',
                met: RegExp(r'\d').hasMatch(passwordController.text),
              ),
            ],

            AppGap.h20,

            // Confirm field
            Text(
              'Confirm Password',
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            TextFormField(
              controller: confirmController,
              obscureText: !showConfirm,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onToggleConfirm,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != passwordController.text)
                  return 'Passwords do not match';
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
                        'Reset Password',
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
