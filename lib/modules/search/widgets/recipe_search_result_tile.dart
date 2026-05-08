import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/meal_type_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeSearchResultTile extends StatelessWidget {
  const RecipeSearchResultTile({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final emoji = MealTypeHelper.emoji(recipe.mealType);
    final lightColor = MealTypeHelper.lightColor(recipe.mealType);

    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: recipe.toMeal()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: recipe.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => ColoredBox(
                        color: lightColor,
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: lightColor,
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                      ),
                    )
                  : ColoredBox(
                      color: lightColor,
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTextStyles.s14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h4,
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.calories} cal',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.prepTime} min',
                          style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    AppGap.h6,
                    if (recipe.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: recipe.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.s12.copyWith(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
