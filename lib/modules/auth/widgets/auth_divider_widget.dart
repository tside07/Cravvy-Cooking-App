import 'package:cravvy_cooking_app/init.dart';

class AuthDividerWidget extends StatelessWidget {
  const AuthDividerWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: AppPad.h12,
          child: Text(
            label,
            style: AppTextStyles.s12.copyWith(color: AppColors.textHint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
