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
      style: context.themed(AppTextStyles.s14),
      decoration: AppInputDecoration.underline.copyWith(
        hintText: hint,
        hintStyle: context.themed(
          AppTextStyles.s14,
          color: context.appColors.inputHint,
        ),
        contentPadding: AppPad.h16v14,
      ),
    );
  }
}
