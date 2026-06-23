import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class PasswordRuleWidget extends StatelessWidget {
  final String label;
  final bool met;

  const PasswordRuleWidget({super.key, required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    final unmet = PreAuthTheme.textDisabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: met ? AppColors.success : unmet,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.s12.copyWith(
              color: met ? AppColors.success : unmet,
            ),
          ),
        ],
      ),
    );
  }
}
