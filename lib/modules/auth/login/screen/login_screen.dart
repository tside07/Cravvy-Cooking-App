import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/login/widgets/forgot_password_button_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (auth.user?.onboardingComplete == true) {
        context.go(AppRouter.app);
      } else {
        context.go(AppRouter.setupStep1);
      }
    } else {
      final error = auth.errorMessage ?? 'auth.login_failed'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreAuthScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const PreAuthBackButton(fallbackRoute: AppRouter.welcomeChoice),
        ),
        body: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) => _Body(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              emailFocus: _emailFocus,
              passwordFocus: _passwordFocus,
              isLoading: auth.status == AuthStatus.loading,
              onSubmit: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool isLoading;
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
                    Text(
                      'auth.login_title'.tr(),
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PreAuthTheme.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      'auth.login_subtitle'.tr(),
                      style: AppTextStyles.s15.copyWith(
                        color: PreAuthTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    AppGap.h28,
                    AuthFormFieldsWidget(
                      preAuth: true,
                      fields: [
                        AuthFormFieldConfig(
                          hint: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocus,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'auth.val_email_required'.tr();
                            }
                            if (!v.contains('@')) {
                              return 'auth.val_email_invalid'.tr();
                            }
                            return null;
                          },
                        ),
                        AuthFormFieldConfig(
                          hint: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          focusNode: passwordFocus,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'auth.val_password_required'.tr();
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const ForgotPasswordButtonWidget(),
                    AppGap.h8,
                    CravvyButton(
                      label: 'auth.sign_in'.tr(),
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
