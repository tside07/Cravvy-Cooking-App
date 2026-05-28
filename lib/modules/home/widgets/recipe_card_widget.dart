import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/init.dart';

class RecipeCardWidget extends StatelessWidget {
  const RecipeCardWidget({super.key, required this.recipe});

  final Meal recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: recipe),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.a20,
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                recipe.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: recipe.type.lightColor,
                  child: Center(
                    child: Text(
                      recipe.type.emoji,
                      style: AppTextStyles.s20.copyWith(fontSize: 34),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppPad.a10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s12.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    '${recipe.calories} cal • ${recipe.prepTime} min',
                    style: AppTextStyles.s12.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
