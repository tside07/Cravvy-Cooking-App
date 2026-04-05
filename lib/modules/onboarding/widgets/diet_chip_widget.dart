import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class DietChipWidget extends StatelessWidget {
  const DietChipWidget({
    super.key,
    required this.diet,
    required this.isSelected,
    required this.onTap,
  });

  final DietType diet;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.a16,
        child: Container(
          padding: AppPad.h14v12,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryLight : AppColors.surface,
            borderRadius: AppBorderRadius.a16,
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(diet.emoji, style: AppTextStyles.s20.copyWith(fontSize: 22)),
              AppGap.w10,
              Expanded(
                child: Text(
                  diet.label,
                  style: AppTextStyles.s14.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.secondaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
