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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withOpacity(0.3)
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
                style: TextStyle(
                  fontSize: 22,
                  color: unlocked ? null : const Color(0x66000000),
                ),
              ),
              const Spacer(),
              if (unlocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✓',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const Icon(Icons.lock_outline_rounded,
                    size: 14, color: AppColors.textHint),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
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
