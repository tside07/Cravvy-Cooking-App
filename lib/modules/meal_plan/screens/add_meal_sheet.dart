import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddMealSheet extends StatefulWidget {
  const AddMealSheet({super.key, required this.date, required this.mealType});

  final DateTime date;
  final MealType mealType;

  @override
  State<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  String get _mealTypeStr {
    switch (widget.mealType) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
      case MealType.snack:
        return 'snack';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: AppPad.t12,
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add ${widget.mealType.label}',
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pick a recipe for this slot',
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppGap.h12,

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.mealType.label.toLowerCase()}...',
                  hintStyle: AppTextStyles.s14.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          AppGap.h12,

          // List
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, rp, _) {
                if (rp.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                var recipes = rp.allRecipes
                    .where((r) => r.mealType == _mealTypeStr)
                    .toList();

                if (_query.isNotEmpty) {
                  recipes = recipes
                      .where(
                        (r) =>
                            r.name.toLowerCase().contains(_query) ||
                            r.tags.any((t) => t.toLowerCase().contains(_query)),
                      )
                      .toList();
                }

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.mealType.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        AppGap.h12,
                        Text(
                          'No ${widget.mealType.label.toLowerCase()} found',
                          style: AppTextStyles.s14.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: recipes.length,
                  itemBuilder: (ctx, i) {
                    final recipe = recipes[i];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await context.read<MealPlanProvider>().addMeal(
                          date: widget.date,
                          mealType: _mealTypeStr,
                          recipe: recipe,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Added ${recipe.name}',
                                style: AppTextStyles.s14.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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
                              child:
                                  recipe.imageUrl != null &&
                                      recipe.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: recipe.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => ColoredBox(
                                        color: widget.mealType.lightColor,
                                        child: Center(
                                          child: Text(
                                            widget.mealType.emoji,
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => ColoredBox(
                                        color: widget.mealType.lightColor,
                                        child: Center(
                                          child: Text(
                                            widget.mealType.emoji,
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ColoredBox(
                                      color: widget.mealType.lightColor,
                                      child: Center(
                                        child: Text(
                                          widget.mealType.emoji,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                            ),
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
                                    if (recipe.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: recipe.tags
                                            .take(2)
                                            .map(
                                              (tag) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  tag,
                                                  style: AppTextStyles.s12
                                                      .copyWith(
                                                        fontSize: 10,
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
