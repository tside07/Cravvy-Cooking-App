import 'package:cravvy_cooking_app/init.dart';

class AuthDividerWidget extends StatelessWidget {
  const AuthDividerWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.borderDivider)),
        Padding(
          padding: AppPad.h12,
          child: Text(
            label,
            style: context.themed(
              AppTextStyles.s12,
              color: colors.textDisabled,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.borderDivider)),
      ],
    );
  }
}
