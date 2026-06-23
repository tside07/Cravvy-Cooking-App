import 'package:cravvy_cooking_app/init.dart';

class AchievementCardWidget extends StatelessWidget {
  const AchievementCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: AppPad.a12,
      decoration: BoxDecoration(
        color: unlocked ? colors.cardSurface : colors.elevated,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.3)
              : colors.borderDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: unlocked
                    ? AppColors.primary
                    : colors.textDisabled.withValues(alpha: 0.6),
              ),
              const Spacer(),
              if (unlocked)
                Container(
                  padding: AppPad.h6v2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppBorderRadius.a6,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                )
              else
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colors.textDisabled,
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: context.themed(
              AppTextStyles.s12,
              color: unlocked ? colors.textPrimary : colors.textDisabled,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            desc,
            style: context.themed(
              AppTextStyles.s10,
              color: colors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
