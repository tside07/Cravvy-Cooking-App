import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class AuthTextFieldWidget extends StatefulWidget {
  const AuthTextFieldWidget({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.preAuth = false,
  });

  final String hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool preAuth;

  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidgetState();
}

class _AuthTextFieldWidgetState extends State<AuthTextFieldWidget> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textColor =
        widget.preAuth ? PreAuthTheme.textPrimary : appColors.textPrimary;
    final hintColor =
        widget.preAuth ? PreAuthTheme.textSecondary : appColors.inputHint;
    final inputStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.s14.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppGap.h6,
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscure,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onFieldSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            }
          },
          style: inputStyle,
          decoration: _decoration(hintColor),
        ),
      ],
    );
  }

  InputDecoration _decoration(Color hintColor) {
    final eyeIcon = widget.isPassword
        ? GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: hintColor,
            ),
          )
        : null;
    final prefix = widget.prefixIcon != null
        ? Icon(widget.prefixIcon, size: 20, color: hintColor)
        : null;

    if (widget.preAuth) {
      return AppInputDecoration.underline.copyWith(
        labelText: widget.hint,
        labelStyle: AppTextStyles.s16.copyWith(color: hintColor),
        floatingLabelStyle: AppTextStyles.s14.copyWith(color: hintColor),
        errorStyle: AppTextStyles.s12.copyWith(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: prefix,
        suffixIcon: eyeIcon,
      );
    }

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: AppTextStyles.s16.copyWith(color: hintColor),
      prefixIcon: prefix,
      suffixIcon: eyeIcon,
    );
  }
}
