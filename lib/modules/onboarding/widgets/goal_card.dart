import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final HealthGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
