import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class MealPlanHeader extends StatelessWidget {
  const MealPlanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meal Plan',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                'Stay on track this week',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '7-day streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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
