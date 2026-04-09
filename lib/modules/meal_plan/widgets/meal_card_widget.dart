import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';

class MealCardWidget extends StatelessWidget {
  const MealCardWidget({
    super.key,
    required this.meal,
    required this.onToggle,
    required this.onSwap,
  });

  final Meal meal;
  final VoidCallback onToggle;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: meal),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ), //TODO: no AppPad equivalent for bottom: 14
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.a20,
          border: Border.all(
            color: meal.isLogged
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            // Meal type header
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                top: 12,
                right: 12,
                bottom: 12,
              ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
              decoration: BoxDecoration(
                color: meal.type.lightColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ), //TODO: no AppBorderRadius equivalent for top-only r20
              ),
              child: Row(
                children: [
                  Text(meal.type.emoji, style: AppTextStyles.s16),
                  AppGap.w8,
                  Text(
                    meal.type.label,
                    style: AppTextStyles.s14.copyWith(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: meal.type.color,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onSwap,
                    child: Container(
                      padding: AppPad.h10v4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppBorderRadius.a20,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: meal.type.color,
                          ),
                          AppGap.w4,
                          Text(
                            'Swap',
                            style: AppTextStyles.s10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: meal.type.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Meal content
            Padding(
              padding: AppPad.a14,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppBorderRadius.a14,
                    child: Image.network(
                      meal.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: meal.type.lightColor,
                        child: Center(
                          child: Text(
                            meal.type.emoji,
                            style: AppTextStyles.s20.copyWith(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppGap.w16,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppGap.h6,
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.local_fire_department_rounded,
                              label: '${meal.calories} cal',
                              color: AppColors.primary,
                            ),
                            AppGap.w8,
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '${meal.prepTime} min',
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        AppGap.h8,
                        Row(
                          children: [
                            _MacroPill(
                              'P ${meal.protein}g',
                              AppColors.secondaryLight,
                              AppColors.secondaryDark,
                            ),
                            AppGap.w4,
                            _MacroPill(
                              'C ${meal.carbs}g',
                              const Color(0xFFFFFAE6),
                              AppColors.accentDark,
                            ),
                            AppGap.w4,
                            _MacroPill(
                              'F ${meal.fat}g',
                              AppColors.primaryLight,
                              AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppGap.w8,
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: meal.isLogged
                            ? AppColors.success
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: meal.isLogged
                              ? AppColors.success
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: meal.isLogged ? Colors.white : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        AppGap.w4,
        Text(
          label,
          style: AppTextStyles.s12.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill(this.label, this.bg, this.textColor);

  final String label;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.h8v4,
      decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.a20),
      child: Text(
        label,
        style: AppTextStyles.s10.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
