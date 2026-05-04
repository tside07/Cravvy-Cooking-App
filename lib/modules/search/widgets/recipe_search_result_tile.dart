import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeSearchResultTile extends StatelessWidget {
  const RecipeSearchResultTile({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final meal = recipe.toMeal();

    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: meal),
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
            // ── Thumbnail ───────────────────────────────────────────────────
            SizedBox(
              width: 80,
              height: 80,
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: recipe.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => ColoredBox(
                        color: meal.type.lightColor,
                        child: Center(
                          child: Text(
                            meal.type.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: meal.type.lightColor,
                        child: Center(
                          child: Text(
                            meal.type.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: meal.type.lightColor,
                      child: Center(
                        child: Text(
                          meal.type.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
            ),

            // ── Info ─────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.calories} cal',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.prepTime} min',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h6,
                    // Tags row
                    if (recipe.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: recipe.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
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

            // ── Arrow ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
