import 'package:cravvy_cooking_app/init.dart';

class AchievementCardWidget extends StatelessWidget {
  const AchievementCardWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.unlocked,
  });

  final String emoji;
  final String title;
  final String desc;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a12,
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: AppTextStyles.s20.copyWith(
                  fontSize: 22,
                  color: unlocked ? null : const Color(0x66000000),
                ),
              ),
              const Spacer(),
              if (unlocked)
                Container(
                  padding: AppPad.h6v2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppBorderRadius.a6,
                  ),
                  child: Text(
                    '✓',
                    style: AppTextStyles.s10.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.textHint,
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.s12.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          Text(
            desc,
            style: AppTextStyles.s10.copyWith(
              color: AppColors.textHint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
