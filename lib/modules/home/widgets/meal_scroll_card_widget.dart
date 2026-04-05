import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';

class MealScrollCardWidget extends StatelessWidget {
  const MealScrollCardWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(
        right: 12,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a20,
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
                        style: AppTextStyles.s20.copyWith(fontSize: 36),
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
                    padding: AppPad.h8v4,
                    decoration: BoxDecoration(
                      color: meal.type.color,
                      borderRadius: AppBorderRadius.a8,
                    ),
                    child: Text(
                      meal.type.emoji,
                      style: AppTextStyles.s12.copyWith(),
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
            padding: AppPad.a10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.s12.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppGap.h4,
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    AppGap.w2,
                    Text(
                      '${meal.calories} cal',
                      style: AppTextStyles.s12.copyWith(
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
