import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';

/// Segmented tab bar: Ingredients | Nutrition | Instructions.
class MealDetailTabsWidget extends StatelessWidget {
  const MealDetailTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<MealDetailProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: Container(
              padding: AppPad.a4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppBorderRadius.a16,
              ),
              child: Row(
                children: MealDetailTab.values.map((tab) {
                  final isActive = provider.activeTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: AppPad.v10,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: AppBorderRadius.a12,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _label(tab),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.s14.copyWith(
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _label(MealDetailTab tab) {
    switch (tab) {
      case MealDetailTab.ingredients:
        return 'Ingredients';
      case MealDetailTab.nutrition:
        return 'Nutrition';
      case MealDetailTab.instructions:
        return 'Instructions';
    }
  }
}
