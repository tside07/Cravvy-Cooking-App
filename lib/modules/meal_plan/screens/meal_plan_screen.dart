import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_plan_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/week_strip_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/calorie_summary_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_card_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/screens/add_meal_sheet.dart';
import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const MealPlanHeaderWidget(),
            const WeekStripWidget(),
            const CalorieSummaryWidget(),
            const Expanded(child: _MealList()),
          ],
        ),
      ),
    );
  }
}

class _MealList extends StatelessWidget {
  const _MealList();

  static const _allSlots = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.status == MealPlanStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 36)),
                AppGap.h12,
                Text(
                  'Không tải được kế hoạch ăn',
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppGap.h12,
                TextButton(
                  onPressed: provider.reload,
                  child: Text(
                    'Thử lại',
                    style: AppTextStyles.s14.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }

        final day = provider.selectedDay;
        final meals = day.meals;

        return RefreshIndicator(
          onRefresh: provider.reload,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 100,
            ),
            itemCount: _allSlots.length,
            itemBuilder: (context, i) {
              final slotType = _allSlots[i];
              final mealOrNull = meals
                  .where((m) => m.type == slotType)
                  .toList();
              final hasMeal = mealOrNull.isNotEmpty;

              if (hasMeal) {
                final meal = mealOrNull.first;
                return MealCardWidget(
                  meal: meal,
                  onToggle: () => provider.toggleMealLogged(meal.id),
                  onSwap: () => _showSwapSheet(context, provider, meal),
                  onRemove: () => provider.removeMeal(
                    date: day.date,
                    mealType: _typeStr(slotType),
                  ),
                );
              }

              return EmptyMealSlotCard(
                mealType: slotType,
                onAdd: () => _showAddSheet(context, day.date, slotType),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context, DateTime date, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<MealPlanProvider>()),
          ChangeNotifierProvider.value(value: context.read<RecipeProvider>()),
        ],
        child: AddMealSheet(date: date, mealType: mealType),
      ),
    );
  }

  void _showSwapSheet(
    BuildContext context,
    MealPlanProvider provider,
    Meal meal,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: MealSwapSheet(meal: meal),
      ),
    );
  }

  String _typeStr(MealType t) {
    switch (t) {
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
}
