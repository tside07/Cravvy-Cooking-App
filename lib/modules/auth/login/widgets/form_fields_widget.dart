
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_text_field_widget.dart';

class FormFieldsWidget extends StatelessWidget {
  const FormFieldsWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextFieldWidget(
          hint: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          focusNode: emailFocus,
          nextFocusNode: passwordFocus,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your email';
            if (!v.contains('@')) return 'Invalid email address';
            return null;
          },
        ),
        AppGap.h12,
        AuthTextFieldWidget(
          hint: 'Password',
          controller: passwordController,
          isPassword: true,
          focusNode: passwordFocus,
          textInputAction: TextInputAction.done,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your password';
            return null;
          },
        ),
      ],
    );
  }
}
