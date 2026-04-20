import 'package:cravvy_cooking_app/init.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _passwordController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'\d').hasMatch(p)) score++;
    return score;
  }

  double get _strengthPct => _strength / 3;

  Color get _strengthColor {
    if (_strengthPct < 0.4) return AppColors.error;
    if (_strengthPct < 0.8) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_strengthPct < 0.4) return 'Weak';
    if (_strengthPct < 0.8) return 'Medium';
    return 'Strong';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: _isSuccess
              ? _SuccessView()
              : _FormView(
                  formKey: _formKey,
                  email: widget.email,
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  showPassword: _showPassword,
                  showConfirm: _showConfirm,
                  isLoading: _isLoading,
                  strengthPct: _strengthPct,
                  strengthColor: _strengthColor,
                  strengthLabel: _strengthLabel,
                  onTogglePassword: () =>
                      setState(() => _showPassword = !_showPassword),
                  onToggleConfirm: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  onPasswordChanged: (_) => setState(() {}),
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
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

  const _FormView({
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGap.h8,
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
            Text(
              'Create New Password',
              style: AppTextStyles.s20.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            AppGap.h8,
            Text(
              'Enter a strong password for $email',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
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
              _PasswordRule(
                label: 'At least 8 characters',
                met: passwordController.text.length >= 8,
              ),
              _PasswordRule(
                label: 'Contains uppercase',
                met: RegExp(r'[A-Z]').hasMatch(passwordController.text),
              ),
              _PasswordRule(
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

class _PasswordRule extends StatelessWidget {
  final String label;
  final bool met;
  const _PasswordRule({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: met ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.s12.copyWith(
              color: met ? AppColors.success : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            AppGap.h24,
            Text(
              'Password Updated!',
              style: AppTextStyles.s20.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            AppGap.h12,
            Text(
              'Your password has been reset successfully.\nRedirecting to login…',
              textAlign: TextAlign.center,
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
