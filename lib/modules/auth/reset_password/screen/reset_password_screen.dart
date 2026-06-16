import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/reset_password_form_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/reset_password_success_widget.dart';
import 'package:easy_localization/easy_localization.dart';

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
    if (_strengthPct < 0.4) return 'auth.password_strength_weak'.tr();
    if (_strengthPct < 0.8) return 'auth.password_strength_medium'.tr();
    return 'auth.password_strength_strong'.tr();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.updatePassword(_passwordController.text);

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go(AppRouter.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeMessage(auth.errorMessage ?? 'auth.reset_failed'),
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.card,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => PreAuthScaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const PreAuthBackButton(),
          ),
          body: SafeArea(
            child: _isSuccess
                ? const ResetPasswordSuccessWidget()
                : ResetPasswordFormWidget(
                    formKey: _formKey,
                    email: widget.email,
                    passwordController: _passwordController,
                    confirmController: _confirmController,
                    showPassword: _showPassword,
                    showConfirm: _showConfirm,
                    isLoading: auth.status == AuthStatus.loading,
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
      ),
    );
  }
}
