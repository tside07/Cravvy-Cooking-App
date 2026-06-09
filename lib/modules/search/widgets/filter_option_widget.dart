import 'package:cravvy_cooking_app/init.dart';

class FilterOptionWidget extends StatelessWidget {
  const FilterOptionWidget({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : colors.chipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : colors.chipBorder,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.s14.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? colors.onPrimary : colors.textPrimary,
        ),
      ),
    );
  }
}
