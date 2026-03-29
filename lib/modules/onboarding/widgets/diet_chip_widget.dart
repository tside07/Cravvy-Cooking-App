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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(diet.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  diet.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? AppColors.secondaryDark
                            : AppColors.textPrimary,
                        fontSize: 13,
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
