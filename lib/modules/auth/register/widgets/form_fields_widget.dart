import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';

class RegisterFormFieldsWidget extends StatelessWidget {
  const RegisterFormFieldsWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmFocus,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;

  @override
  Widget build(BuildContext context) {
    return AuthFormFieldsWidget(
      fields: [
        AuthFormFieldConfig(
          hint: 'Full Name',
          controller: nameController,
          keyboardType: TextInputType.name,
          focusNode: nameFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty)
              return 'Please enter your full name';
            return null;
          },
        ),
        AuthFormFieldConfig(
          hint: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocus,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your email';
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
            if (v == null || v.isEmpty) return 'Please enter a password';
            if (v.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        AuthFormFieldConfig(
          hint: 'Confirm Password',
          controller: confirmPasswordController,
          isPassword: true,
          focusNode: confirmFocus,
          validator: (v) {
            if (v != passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }
}
