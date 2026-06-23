import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/register/widgets/form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/register/widgets/terms_checkbox_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_brand_mark_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'auth.val_terms'.tr(),
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Đăng ký xong → vào setup step 1 (onboarding chưa xong)
      context.go(AppRouter.setupStep1);
    } else {
      final error = localizeMessage(
        auth.errorMessage ?? 'auth.register_failed',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreAuthScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const PreAuthBackButton(),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => _Body(
            formKey: _formKey,
            nameController: _nameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            nameFocus: _nameFocus,
            emailFocus: _emailFocus,
            passwordFocus: _passwordFocus,
            confirmFocus: _confirmFocus,
            isLoading: auth.status == AuthStatus.loading,
            agreedToTerms: _agreedToTerms,
            onAgreedChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.isLoading,
    required this.agreedToTerms,
    required this.onAgreedChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;
  final bool isLoading;
  final bool agreedToTerms;
  final ValueChanged<bool?> onAgreedChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 768 ? 32.0 : 24.0;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h12,
                    const AuthBrandMark(),
                    AppGap.h24,
                    Text(
                      'auth.register_title'.tr(),
                      style: AppTextStyles.h1.copyWith(
                        color: PreAuthTheme.textPrimary,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      'auth.register_subtitle'.tr(),
                      style: AppTextStyles.s15.copyWith(
                        color: PreAuthTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    AppGap.h28,
                    RegisterFormFieldsWidget(
                      nameController: nameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      nameFocus: nameFocus,
                      emailFocus: emailFocus,
                      passwordFocus: passwordFocus,
                      confirmFocus: confirmFocus,
                    ),
                    AppGap.h16,
                    TermsCheckboxWidget(
                      agreedToTerms: agreedToTerms,
                      onChanged: onAgreedChanged,
                    ),
                    AppGap.h24,
                    CravvyButton(
                      label: 'auth.create_account'.tr(),
                      isLoading: isLoading,
                      onTap: onSubmit,
                    ),
                    AppGap.h24,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
