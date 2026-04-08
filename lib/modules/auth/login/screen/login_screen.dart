import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_divider_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/login/widgets/forgot_password_button_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/login/widgets/register_link_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_section_widget.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: _Body(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            emailFocus: _emailFocus,
            passwordFocus: _passwordFocus,
            isLoading: _isLoading,
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
    return SingleChildScrollView(
      padding: AppPad.h24,
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

            AuthSocialSectionWidget(onGoogleTap: () {}, onAppleTap: () {}),
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
                    if (v == null || v.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) return 'Invalid email address';
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
                      return 'Please enter your password';
                    }
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
    );
  }
}
