import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.read<OnboardingProvider>().selectedGoal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  goal != null
                      ? 'Goal: ${goal.title}'
                      : 'Monday, Let\'s eat healthy!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
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
                const Text(
                  '7-day streak',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
