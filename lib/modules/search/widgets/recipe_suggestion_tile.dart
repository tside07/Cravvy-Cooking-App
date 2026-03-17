import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class RecipeSuggestionTile extends StatelessWidget {
  const RecipeSuggestionTile({super.key, required this.recipe});

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
                Text(name, style: Theme.of(context).textTheme.titleMedium),
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
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
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
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              const Text(
                'match',
                style: TextStyle(
                  fontFamily: 'Nunito',
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
