// lib/modules/meal_plan/screens/meal_plan_screen.dart

import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/meal_plan_header_widget.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/widgets/free_week_upsell_banner.dart';
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
            const FreeWeekUpsellBanner(),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'AI đang gợi ý thực đơn...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _allSlots.length + 1, // +1 cho banner
            itemBuilder: (context, i) {
              // Index 0: banner "Làm mới gợi ý"
              if (i == 0) {
                return _RefreshSuggestionBanner(
                  onRefresh: () => _confirmRefresh(context, provider),
                );
              }

              final slotType = _allSlots[i - 1];
              final match = meals.where((m) => m.type == slotType).toList();

              if (match.isNotEmpty) {
                final meal = match.first;
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
          'Làm mới gợi ý?',
          style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Toàn bộ thực đơn tuần này sẽ được gợi ý lại theo mục tiêu của bạn.',
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.autoFillWeek(forceRefresh: true);
            },
            child: Text(
              'Làm mới',
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
              'Thực đơn được gợi ý theo mục tiêu của bạn',
              style: AppTextStyles.s12.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGap.w8,
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Làm mới',
                style: AppTextStyles.s12.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
