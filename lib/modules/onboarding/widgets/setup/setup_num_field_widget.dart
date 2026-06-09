import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class SetupNumFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const SetupNumFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: AppTextStyles.s14.copyWith(color: PreAuthTheme.textPrimary),
      cursorColor: PreAuthTheme.textPrimary,
      decoration: AppInputDecoration.underline.copyWith(
        hintText: hint,
        hintStyle: AppTextStyles.s14.copyWith(color: PreAuthTheme.textSecondary),
        contentPadding: AppPad.h16v14,
      ),
    );
  }
}
