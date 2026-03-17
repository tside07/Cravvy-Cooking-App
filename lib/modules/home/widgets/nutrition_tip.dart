import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class NutritionTip extends StatelessWidget {
  const NutritionTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Drink water 30 min before meals to help with digestion and portion control.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
