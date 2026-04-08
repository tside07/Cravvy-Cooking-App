import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_auth_app_bar.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/icon_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/back_to_login_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/note_box_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call send OTP service
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push(AppRouter.otp, extra: _emailController.text.trim());
      }
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
          emailController: _emailController,
          isLoading: _isLoading,
          onSubmit: _sendOtp,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppPad.h24,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppGap.h16,
            const IconSectionWidget(icon: Icons.mail_outline_rounded),
            AppGap.h28,
            const AuthHeaderWidget(
              title: 'Forgot Password?',
              subtitle:
                  "Don't worry! Enter your registered email address and we will send you an OTP code to verify your identity.",
              textAlign: TextAlign.center,
            ),
            AppGap.h36,
            AuthFormFieldsWidget(
              fields: [
                AuthFormFieldConfig(
                  hint: 'Enter your email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please enter your email';
                    if (!v.contains('@')) return 'Invalid email address';
                    return null;
                  },
                ),
              ],
            ),
            AppGap.h28,
            CravvyButton(
              label: 'SEND OTP',
              isLoading: isLoading,
              onTap: onSubmit,
            ),
            AppGap.h16,
            const BackToLoginWidget(),
            AppGap.h24,
            const NoteBoxWidget(),
            AppGap.h24,
          ],
        ),
      ),
    );
  }
}
