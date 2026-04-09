import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/diet_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/onboarding_progress_widget.dart';

class DietSelectionScreen extends StatelessWidget {
  const DietSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppPad.h24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGap.h16,
              const OnboardingProgressWidget(current: 2, total: 2),
              AppGap.h32,

              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRouter.goalSelection),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Your diet type 🌿',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              AppGap.h8,
              Text(
                'Select all that apply — we\'ll filter your recipes.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              AppGap.h28,

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
                        return DietChipWidget(
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
              AppGap.h24,
            ],
          ),
        ),
      ),
    );
  }
}
