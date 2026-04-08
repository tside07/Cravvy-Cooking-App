import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_text_field_widget.dart';

class AuthFormFieldsWidget extends StatelessWidget {
  const AuthFormFieldsWidget({super.key, required this.fields});

  final List<AuthFormFieldConfig> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          AuthTextFieldWidget(
            hint: fields[i].hint,
            controller: fields[i].controller,
            keyboardType: fields[i].keyboardType,
            isPassword: fields[i].isPassword,
            prefixIcon: fields[i].prefixIcon,
            focusNode: fields[i].focusNode,
            nextFocusNode: i < fields.length - 1
                ? fields[i + 1].focusNode
                : null,
            textInputAction: i < fields.length - 1
                ? TextInputAction.next
                : TextInputAction.done,
            validator: fields[i].validator,
            onChanged: fields[i].onChanged,
          ),
          if (i < fields.length - 1) AppGap.h12,
        ],
      ],
    );
  }
}

class AuthFormFieldConfig {
  const AuthFormFieldConfig({
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.focusNode,
    this.validator,
    this.onChanged,
  });

  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
}
