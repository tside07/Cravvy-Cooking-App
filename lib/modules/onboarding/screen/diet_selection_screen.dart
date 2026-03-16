import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/cravvy_button.dart';
import 'goal_selection_screen.dart' show _OnboardingProgress;

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
              _OnboardingProgress(current: 2, total: 2),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: DietType.values.length,
                      itemBuilder: (context, i) {
                        final diet = DietType.values[i];
                        final isSelected = provider.isDietSelected(diet);
                        return _DietChip(
                          diet: diet,
                          isSelected: isSelected,
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
                      ? () => context.go(AppRouter.setupComplete)
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

class _DietChip extends StatelessWidget {
  final DietType diet;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietChip({
    required this.diet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(diet.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  diet.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? AppColors.secondaryDark
                        : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.secondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
