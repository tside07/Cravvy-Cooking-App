import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
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
      preAuth: true,
      fields: [
        AuthFormFieldConfig(
          hint: 'auth.hint_full_name'.tr(),
          controller: nameController,
          keyboardType: TextInputType.name,
          focusNode: nameFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'auth.val_name_required'.tr();
            }
            return null;
          },
        ),
        AuthFormFieldConfig(
          hint: 'auth.email_hint'.tr(),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocus,
          validator: (v) {
            if (v == null || v.isEmpty) return 'auth.val_email_required'.tr();
            if (!v.contains('@')) return 'auth.val_email_invalid'.tr();
            return null;
          },
        ),
        AuthFormFieldConfig(
          hint: 'auth.password_hint'.tr(),
          controller: passwordController,
          isPassword: true,
          focusNode: passwordFocus,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'auth.val_password_required'.tr();
            }
            if (v.length < 6) return 'auth.val_password_min_6'.tr();
            return null;
          },
        ),
        AuthFormFieldConfig(
          hint: 'auth.hint_confirm_password'.tr(),
          controller: confirmPasswordController,
          isPassword: true,
          focusNode: confirmFocus,
          validator: (v) {
            if (v != passwordController.text) {
              return 'auth.val_password_mismatch'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
