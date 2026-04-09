import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/models/meal_detail_ingredient.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';

/// A single ingredient row: checkbox | quantity + name | status icon.
class MealDetailIngredientItemWidget extends StatelessWidget {
  const MealDetailIngredientItemWidget({
    super.key,
    required this.ingredient,
    required this.index,
  });

  final MealDetailIngredient ingredient;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<MealDetailProvider>(
      builder: (context, provider, _) {
        final checked = provider.isChecked(index);
        return InkWell(
          onTap: () => provider.toggleChecked(index),
          borderRadius: AppBorderRadius.a12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Checkbox ────────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: checked
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: AppBorderRadius.a6,
                    border: Border.all(
                      color: checked
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                AppGap.w14,

                // ── Quantity + name ──────────────────────────────────────────
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${ingredient.quantity} ',
                          style: AppTextStyles.s14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: checked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        TextSpan(
                          text: ingredient.name,
                          style: AppTextStyles.s14.copyWith(
                            fontWeight: FontWeight.w500,
                            color: checked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppGap.w8,

                // ── Status icon ──────────────────────────────────────────────
                _StatusIcon(status: ingredient.status),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final IngredientStatus status;

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == IngredientStatus.available;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.successLight
            : AppColors.warningLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAvailable
            ? Icons.check_rounded
            : Icons.priority_high_rounded,
        size: 15,
        color: isAvailable ? AppColors.success : AppColors.warning,
      ),
    );
  }
}
