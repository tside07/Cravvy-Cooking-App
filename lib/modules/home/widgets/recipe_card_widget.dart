import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/models/meal_type_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

enum RecipeCardLayout { compact, featured, grid }

class RecipeCardWidget extends StatelessWidget {
  const RecipeCardWidget({
    super.key,
    required this.recipe,
    this.layout = RecipeCardLayout.compact,
  });

  final Recipe recipe;
  final RecipeCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    switch (layout) {
      case RecipeCardLayout.compact:
        return _buildCompact(context);
      case RecipeCardLayout.featured:
        return _buildFeatured(context);
      case RecipeCardLayout.grid:
        return _buildGrid(context);
    }
  }

  Widget _buildCompact(BuildContext context) => _buildCard(
        context,
        width: 160,
        imageHeight: 110,
        margin: AppPad.r12,
      );

  Widget _buildFeatured(BuildContext context) => _buildCard(
        context,
        width: 180,
        imageHeight: 150,
        margin: AppPad.r12,
      );

  Widget _buildGrid(BuildContext context) {
    final emoji = MealTypeHelper.emoji(recipe.mealType);
    final lightColor = MealTypeHelper.lightColor(recipe.mealType);

    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: recipe.toMeal()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 180 / 150,
              child: _buildRecipePhoto(emoji, lightColor),
            ),
          ),
          const SizedBox(height: 10),
          _buildRecipeMeta(context, padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double width,
    required double imageHeight,
    EdgeInsetsGeometry? margin,
  }) {
    final colors = context.appColors;
    final emoji = MealTypeHelper.emoji(recipe.mealType);
    final lightColor = MealTypeHelper.lightColor(recipe.mealType);
    final typeColor = MealTypeHelper.color(recipe.mealType);

    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: recipe.toMeal()),
      child: Container(
        width: width,
        margin: margin,
        decoration: context.cardBox(radius: 16),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildRecipePhoto(emoji, lightColor),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(emoji, style: AppTextStyles.s12),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor(recipe.difficulty, colors),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: AppTextStyles.s12.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildRecipeMeta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipePhoto(String emoji, Color lightColor) {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => ColoredBox(
          color: lightColor,
          child: Center(
            child: Text(
              emoji,
              style: AppTextStyles.s20.copyWith(fontSize: 32),
            ),
          ),
        ),
        errorWidget: (context, url, error) => ColoredBox(
          color: lightColor,
          child: Center(
            child: Text(
              emoji,
              style: AppTextStyles.s20.copyWith(fontSize: 32),
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: lightColor,
      child: Center(
        child: Text(
          emoji,
          style: AppTextStyles.s20.copyWith(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildRecipeMeta(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    final colors = context.appColors;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.name,
            style: context.themed(
              AppTextStyles.s12,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppGap.h6,
          _buildCalorieTimeRow(colors),
        ],
      ),
    );
  }

  Widget _buildCalorieTimeRow(AppColorExtension colors) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 12,
          color: AppColors.primary,
        ),
        const SizedBox(width: 2),
        Text(
          '${recipe.calories} ${'meal_plan.calories_unit'.tr()}',
          style: AppTextStyles.s12.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.timer_outlined,
          size: 11,
          color: colors.textSecondary,
        ),
        const SizedBox(width: 2),
        Text(
          '${recipe.prepTime}${'meal_plan.minutes_short'.tr()}',
          style: AppTextStyles.s12.copyWith(
            fontSize: 11,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _difficultyColor(String difficulty, AppColorExtension colors) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return colors.textSecondary;
    }
  }
}
