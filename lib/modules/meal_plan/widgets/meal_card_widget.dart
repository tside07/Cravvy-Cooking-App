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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: meal.type.lightColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(meal.type.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  meal.type.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: meal.type.color,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSwap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: 14, color: meal.type.color),
                        const SizedBox(width: 4),
                        Text(
                          'Swap',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
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
                        child: Text(meal.type.emoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.local_fire_department_rounded,
                            label: '${meal.calories} cal',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label: '${meal.prepTime} min',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MacroPill('P ${meal.protein}g',
                              AppColors.secondaryLight, AppColors.secondaryDark),
                          const SizedBox(width: 4),
                          _MacroPill('C ${meal.carbs}g',
                              const Color(0xFFFFFAE6), AppColors.accentDark),
                          const SizedBox(width: 4),
                          _MacroPill('F ${meal.fat}g', AppColors.primaryLight,
                              AppColors.primaryDark),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
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
                      color:
                          meal.isLogged ? Colors.white : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
