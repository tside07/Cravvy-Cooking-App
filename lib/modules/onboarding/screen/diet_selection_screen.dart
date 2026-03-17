import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import '../widgets/diet_chip.dart';
import '../widgets/onboarding_progress.dart';

class DietSelectionScreen extends StatelessWidget {
  const DietSelectionScreen({super.key});

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
              const OnboardingProgress(current: 2, total: 2),
              const SizedBox(height: 32),

              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRouter.goalSelection),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your diet type 🌿',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply — we\'ll filter your recipes.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),

              Expanded(
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: DietType.values.length,
                      itemBuilder: (context, i) {
                        final diet = DietType.values[i];
                        return DietChip(
                          diet: diet,
                          isSelected: provider.isDietSelected(diet),
                          onTap: () => provider.toggleDiet(diet),
                        );
                      },
                    );
                  },
                ),
              ),

              Consumer<OnboardingProvider>(
                builder: (context, provider, _) => CravvyButton(
                  label: 'Start Planning →',
                  onTap: provider.canProceedDiet
                      ? () => context.go(
                            AppRouter.setupComplete,
                            extra: OnboardingArgs(
                              goal: provider.selectedGoal,
                              diets: provider.selectedDiets,
                            ),
                          )
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
