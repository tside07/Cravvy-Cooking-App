import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';

class MealScrollCardWidget extends StatelessWidget {
  const MealScrollCardWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          SizedBox(
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: meal.type.lightColor,
                    child: Center(
                      child: Text(
                        meal.type.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xAA000000)],
                    ),
                  ),
                ),
                // Meal type badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: meal.type.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meal.type.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                // Logged check
                if (meal.isLogged)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${meal.calories} cal',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
