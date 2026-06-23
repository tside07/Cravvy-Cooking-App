import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/meal_scroll_card_widget.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton_layouts.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';

class TodayMealsSectionWidget extends StatelessWidget {
  const TodayMealsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.todayDay.meals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 16,
                right: 24,
                bottom: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home.meals_title'.tr(),
                    style: context.themed(AppTextStyles.h2),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<DashboardTabProvider>().switchTo(1),
                    child: Row(
                      children: [
                        Text(
                          'home.see_all'.tr(),
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading state — skeleton row matching the meal scroll cards.
            if (provider.isLoading)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppPad.h16,
                  itemCount: 4,
                  itemBuilder: (_, _) => const RecipeCardSkeleton(
                    width: 150,
                    imageHeight: 110,
                  ),
                ),
              )
            // Empty state — chưa có meal nào hôm nay
            else if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.read<DashboardTabProvider>().switchTo(1),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: context.cardBox(radius: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 32,
                          color: context.appColors.textSecondary,
                        ),
                        AppGap.h8,
                        Text(
                          'home.no_meals_title'.tr(),
                          style: context.themed(
                            AppTextStyles.s14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          'home.no_meals_desc'.tr(),
                          style: context.themed(
                            AppTextStyles.s12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // Has meals
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppPad.h16,
                  itemCount: meals.length,
                  itemBuilder: (context, i) =>
                      MealScrollCardWidget(meal: meals[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
