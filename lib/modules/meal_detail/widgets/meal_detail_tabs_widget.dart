import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';

/// Segmented tab bar: Ingredients | Nutrition | Instructions.
class MealDetailTabsWidget extends StatelessWidget {
  const MealDetailTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SliverToBoxAdapter(
      child: Consumer<MealDetailProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: Container(
              padding: AppPad.a4,
              decoration: BoxDecoration(
                color: colors.elevated,
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
                          color: isActive ? colors.cardSurface : Colors.transparent,
                          borderRadius: AppBorderRadius.a12,
                          border: isActive
                              ? Border.all(color: colors.borderDivider)
                              : null,
                        ),
                        child: Text(
                          _label(tab),
                          textAlign: TextAlign.center,
                          style: context.themed(
                            AppTextStyles.s14,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : colors.textSecondary,
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
        return 'meal_detail.tab_ingredients'.tr();
      case MealDetailTab.nutrition:
        return 'meal_detail.tab_nutrition'.tr();
      case MealDetailTab.instructions:
        return 'meal_detail.tab_instructions'.tr();
    }
  }
}
