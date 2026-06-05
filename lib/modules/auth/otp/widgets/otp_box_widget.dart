import 'package:cravvy_cooking_app/init.dart';

class OtpBoxWidget extends StatelessWidget {
  const OtpBoxWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: onChanged,
        style: AppTextStyles.s20.copyWith(
          fontWeight: FontWeight.w800,
          color: appColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.text.isEmpty
              ? AppColors.surfaceVariant
              : AppColors.primaryLight,
          enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.a12,
            borderSide: BorderSide(
              color: controller.text.isEmpty
                  ? AppColors.border
                  : AppColors.primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.a12,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
