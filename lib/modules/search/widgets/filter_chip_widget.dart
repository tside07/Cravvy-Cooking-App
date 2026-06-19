import 'package:cravvy_cooking_app/init.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.chipSelectedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.chipSelectedBorder),
      ),
      child: Text(
        label,
        style: AppTextStyles.s12.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
