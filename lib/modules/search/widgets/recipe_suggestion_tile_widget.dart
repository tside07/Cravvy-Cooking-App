import 'package:cravvy_cooking_app/init.dart';

class RecipeSuggestionTileWidget extends StatelessWidget {
  const RecipeSuggestionTileWidget({super.key, required this.recipe});

  /// (name, calories, time, emoji, matchPercent)
  final (String, String, String, String, int) recipe;

  @override
  Widget build(BuildContext context) {
    final (name, cal, time, emoji, match) = recipe;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.s16.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    Text(
                      ' $cal · ⏱ $time',
                      style: AppTextStyles.s12.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
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
                'match',
                style: AppTextStyles.s12.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
