import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_plan_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/week_strip_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/calorie_summary_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_card_widget.dart';
import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
<<<<<<< Updated upstream
        child: Column(
          children: [
            const MealPlanHeaderWidget(),
            const WeekStripWidget(),
            const CalorieSummaryWidget(),
            const Expanded(child: _MealList()),
          ],
=======
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = _responsiveHorizontalPadding(
              constraints.maxWidth,
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  children: [
                    const MealPlanHeaderWidget(),
                    const WeekStripWidget(),
                    const FreeWeekUpsellBanner(),
                    const CalorieSummaryWidget(),
                    Expanded(
                      child: _MealList(horizontalPadding: horizontalPadding),
                    ),
                  ],
                ),
              ),
            );
          },
>>>>>>> Stashed changes
        ),
      ),
    );
  }

  double _responsiveHorizontalPadding(double maxWidth) {
    if (maxWidth >= 1024) return 32;
    if (maxWidth >= 768) return 28;
    if (maxWidth >= 600) return 20;
    return 16;
  }
}

class _MealList extends StatelessWidget {
  const _MealList({required this.horizontalPadding});

<<<<<<< Updated upstream
=======
  static const _allSlots = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ];
  final double horizontalPadding;

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.selectedDay.meals;
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: 100,
          ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
          itemCount: meals.length,
          itemBuilder: (context, i) => MealCardWidget(
            meal: meals[i],
            onToggle: () => provider.toggleMealLogged(meals[i].id),
            onSwap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: MealSwapSheet(meal: meals[i]),
              ),
            ),
<<<<<<< Updated upstream
=======
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
                  'meal_plan.load_error'.tr(),
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppGap.h12,
                TextButton(
                  onPressed: provider.reload,
                  child: Text(
                    'meal_plan.retry'.tr(),
                    style: AppTextStyles.s14.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }

        final day = provider.selectedDay;
        final meals = day.meals;
        final mealByType = {for (final meal in meals) meal.type: meal};

        return RefreshIndicator(
          onRefresh: provider.reload,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 100),
            itemCount: _allSlots.length + 1, // +1 cho banner
            itemBuilder: (context, i) {
              // Index 0: banner "Làm mới gợi ý"
              if (i == 0) {
                return _RefreshSuggestionBanner(
                  onRefresh: () => _confirmRefresh(context, provider),
                );
              }

              final slotType = _allSlots[i - 1];
              final meal = mealByType[slotType];
              if (meal != null) {
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
>>>>>>> Stashed changes
          ),
        );
      },
    );
  }
<<<<<<< Updated upstream
=======

  Future<void> _confirmRefresh(
    BuildContext context,
    MealPlanProvider provider,
  ) async {
    final can = await provider.canForceRefreshWeek();
    if (!context.mounted) return;
    if (!can) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('limits.ai_refresh_exhausted'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'meal_plan.refresh_dialog_title'.tr(),
          style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'meal_plan.refresh_dialog_body'.tr(),
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.cancel'.tr(),
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.autoFillWeek(forceRefresh: true);
            },
            child: Text(
              'meal_plan.refresh'.tr(),
              style: AppTextStyles.s14.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: context.read<RecipeProvider>()),
        ],
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

class _RefreshSuggestionBanner extends StatelessWidget {
  const _RefreshSuggestionBanner({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 14)),
          AppGap.w8,
          Expanded(
            child: Text(
              'meal_plan.banner_hint'.tr(),
              style: AppTextStyles.s12.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGap.w8,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRefresh,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'meal_plan.refresh'.tr(),
                  style: AppTextStyles.s12.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
>>>>>>> Stashed changes
}
