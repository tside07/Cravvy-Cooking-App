import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import '../widgets/goal_card.dart';
import '../widgets/onboarding_progress.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const OnboardingProgress(current: 1, total: 2),
              const SizedBox(height: 32),
              Text(
                'What\'s your\nmain goal? 🎯',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll tailor your meal plan around this.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 36),

              // Goal list
              Expanded(
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      itemCount: HealthGoal.values.length,
                      itemBuilder: (context, i) {
                        final goal = HealthGoal.values[i];
                        return GoalCard(
                          goal: goal,
                          isSelected: provider.selectedGoal == goal,
                          onTap: () => provider.selectGoal(goal),
                        );
                      },
                    );
                  },
                ),
              ),

              Consumer<OnboardingProvider>(
                builder: (context, provider, _) => CravvyButton(
                  label: 'Continue',
                  onTap: provider.canProceedGoal
                      ? () => context.go(AppRouter.dietSelection)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
