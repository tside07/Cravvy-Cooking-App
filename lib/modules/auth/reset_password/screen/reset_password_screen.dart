import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/reset_password_form_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/reset_password/widgets/reset_password_success_widget.dart';

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
              ? const ResetPasswordSuccessWidget()
              : ResetPasswordFormWidget(
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
