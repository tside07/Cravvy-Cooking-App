import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/alternative_tile_widget.dart';

class MealSwapSheet extends StatelessWidget {
  const MealSwapSheet({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final alternatives = MealData.getAlternatives(meal.type);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: AppPad.t12,
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppBorderRadius.a2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swap Meal',
                        style: AppTextStyles.s18.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Choose a replacement for ${meal.name}',
                        style: AppTextStyles.s14
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
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
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: AppPad.a12,
            decoration: BoxDecoration(
              color: meal.type.lightColor,
              borderRadius: AppBorderRadius.a16,
              border: Border.all(color: meal.type.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: meal.type.color),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Replacing: ${meal.name}',
                    style: AppTextStyles.s14.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: meal.type.color,
                    ),
                  ),
                ),
                Text(
                  '${meal.calories} kcal',
                  style: AppTextStyles.s12.copyWith(color: meal.type.color),
                ),
              ],
            ),
          ),
          AppGap.h16,
          Expanded(
            child: ListView.builder(
              padding: AppPad.h16,
              itemCount: alternatives.length,
              itemBuilder: (context, i) => AlternativeTileWidget(
                meal: alternatives[i],
                originalCalories: meal.calories,
                onSelect: () {
                  context.read<MealPlanProvider>().swapMeal(
                        meal.id,
                        alternatives[i],
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Swapped to ${alternatives[i].name}',
                        style: AppTextStyles.s14.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.a12,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
