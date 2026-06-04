import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_divider_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/login/widgets/forgot_password_button_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/login/widgets/register_link_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_section_connected.dart';
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
      // Kiểm tra onboarding xong chưa
      if (auth.user?.onboardingComplete == true) {
        context.go(AppRouter.app);
      } else {
        context.go(AppRouter.setupStep1);
      }
    } else {
      // Hiển thị lỗi
      final error = auth.errorMessage ?? 'Đăng nhập thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: AppTextStyles.s14.copyWith(color: AppColors.white)),
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
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Consumer<AuthProvider>(
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
                    AppGap.h20,

            const AuthHeaderWidget(
              title: 'Welcome Back!',
              subtitle: 'Sign in to continue your healthy food journey',
            ),
            AppGap.h28,

                    const AuthSocialSectionConnected(),
                    AppGap.h20,

            const AuthDividerWidget(label: 'or sign in with email'),
            AppGap.h20,

                    AuthFormFieldsWidget(
                      fields: [
                        AuthFormFieldConfig(
                          hint: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocus,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                            if (!v.contains('@')) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        AuthFormFieldConfig(
                          hint: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          focusNode: passwordFocus,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                            return null;
                          },
                        ),
                      ],
                    ),

                    const ForgotPasswordButtonWidget(),
                    AppGap.h8,

                    CravvyButton(
                      label: 'Sign In',
                      isLoading: isLoading,
                      onTap: onSubmit,
                    ),
                    AppGap.h20,

                    const RegisterLinkWidget(),
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