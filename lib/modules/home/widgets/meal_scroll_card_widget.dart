import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/common/widgets/images/recipe_image_placeholder.dart';
import 'package:easy_localization/easy_localization.dart';

class MealScrollCardWidget extends StatelessWidget {
  const MealScrollCardWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: meal),
      child: Container(
        width: 150,
        margin: AppPad.r12,
        decoration: context.cardBox(radius: 16),
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
                    errorBuilder: (_, __, ___) => RecipeImagePlaceholder(
                      icon: meal.type.icon,
                      color: meal.type.color,
                      lightColor: meal.type.lightColor,
                      name: meal.name,
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
                      child: Icon(
                        meal.type.icon,
                        size: 14,
                        color: Colors.white,
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
                    style: context.themed(
                      AppTextStyles.s12,
                      fontWeight: FontWeight.w700,
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
                        '${meal.calories} ${'meal_plan.calories_unit'.tr()}',
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
      ),
    );
  }
}
