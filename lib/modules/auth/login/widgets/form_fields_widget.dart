import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

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
          hint: 'auth.email_hint'.tr(),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          focusNode: emailFocus,
          nextFocusNode: passwordFocus,
          preAuth: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'auth.val_email_required'.tr();
            if (!v.contains('@')) return 'auth.val_email_invalid'.tr();
            return null;
          },
        ),
        AppGap.h12,
        AuthTextFieldWidget(
          hint: 'auth.password_hint'.tr(),
          controller: passwordController,
          isPassword: true,
          focusNode: passwordFocus,
          textInputAction: TextInputAction.done,
          preAuth: true,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'auth.val_password_required'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
