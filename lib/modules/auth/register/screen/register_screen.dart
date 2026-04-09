import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_auth_app_bar.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_divider_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/register/widgets/form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/register/widgets/terms_checkbox_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/register/widgets/login_link_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

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
  bool _isLoading = false;
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

  void _submit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the terms and conditions.',
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
    setState(() => _isLoading = true);
    // TODO: call auth service
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAuthAppBar(),
      body: SafeArea(
        child: _Body(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          nameFocus: _nameFocus,
          emailFocus: _emailFocus,
          passwordFocus: _passwordFocus,
          confirmFocus: _confirmFocus,
          isLoading: _isLoading,
          agreedToTerms: _agreedToTerms,
          onAgreedChanged: (v) => setState(() => _agreedToTerms = v ?? false),
          onSubmit: _submit,
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
    return SingleChildScrollView(
      padding: AppPad.h24,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGap.h8,
            const AuthHeaderWidget(
              title: 'Create Account',
              subtitle: 'Start your healthy food journey',
            ),
            AppGap.h28,
            AuthSocialSectionWidget(onGoogleTap: () {}, onAppleTap: () {}),
            AppGap.h20,
            const AuthDividerWidget(label: 'or sign up with email'),
            AppGap.h20,
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
              label: 'Create Account',
              isLoading: isLoading,
              onTap: onSubmit,
            ),
            AppGap.h20,
            const LoginLinkWidget(),
            AppGap.h24,
          ],
        ),
      ),
    );
  }
}
