import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class SetupSelectChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SetupSelectChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: AppPad.h16v10,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFF2A3A44),
          borderRadius: AppBorderRadius.a50,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : PreAuthTheme.textSecondary.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.s14.copyWith(
            color: selected ? Colors.white : PreAuthTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
