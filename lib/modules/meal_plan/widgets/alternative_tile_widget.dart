import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:easy_localization/easy_localization.dart';

class AlternativeTileWidget extends StatelessWidget {
  const AlternativeTileWidget({
    super.key,
    required this.meal,
    required this.originalCalories,
    required this.onSelect,
  });

  final Meal meal;
  final int originalCalories;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final calDiff = meal.calories - originalCalories;
    final isLower = calDiff < 0;
    final diffColor = isLower ? AppColors.success : AppColors.warning;

    return Container(
      margin: AppPad.b12,
      decoration: context.cardBox(radius: 18),
      child: InkWell(
        onTap: onSelect,
        borderRadius: AppBorderRadius.a18,
        child: Padding(
          padding: AppPad.a14,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.a12,
                child: Image.network(
                  meal.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: meal.type.lightColor,
                    child: Center(
                      child: Icon(
                        meal.type.icon,
                        color: meal.type.color,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: context.themed(
                        AppTextStyles.s16.copyWith(fontSize: 15),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h4,
                    Row(
                      children: [
                        Text(
                          '${meal.calories} ${'meal_plan.kcal_unit'.tr()}',
                          style: context.themed(
                            AppTextStyles.s14.copyWith(fontSize: 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppGap.w6,
                        Container(
                          padding: AppPad.h6v2,
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.a6,
                          ),
                          child: Text(
                            '${isLower ? '' : '+'}$calDiff',
                            style: AppTextStyles.s12.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: diffColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppGap.h6,
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: meal.tags
                          .take(2)
                          .map(
                            (tag) => Container(
                              padding: AppPad.h6v2,
                              decoration: BoxDecoration(
                                color: colors.elevated,
                                borderRadius: AppBorderRadius.a6,
                              ),
                              child: Text(
                                tag,
                                style: context.themed(
                                  AppTextStyles.s10,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
