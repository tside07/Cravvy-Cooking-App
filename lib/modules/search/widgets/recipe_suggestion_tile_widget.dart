import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class RecipeSuggestionTileWidget extends StatelessWidget {
  const RecipeSuggestionTileWidget({super.key, required this.recipe});

  /// (name, calories, time, emoji, matchPercent)
  final (String, String, String, String, int) recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (name, cal, time, emoji, match) = recipe;
    return Container(
      margin: AppPad.b10,
      padding: AppPad.a14,
      decoration: context.cardBox(radius: 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppBorderRadius.a12,
            ),
            child: Center(
              child: Text(
                emoji,
                style: AppTextStyles.s20.copyWith(fontSize: 26),
              ),
            ),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.themed(
                    AppTextStyles.s16,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 15),
                ),
                AppGap.h4,
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    Text(
                      ' $cal · ⏱ $time',
                      style: context.themed(
                        AppTextStyles.s12,
                        color: colors.textSecondary,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$match%',
                style: AppTextStyles.s16.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              Text(
                'search.match'.tr(),
                style: context.themed(
                  AppTextStyles.s12,
                  color: colors.textSecondary,
                ).copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
  