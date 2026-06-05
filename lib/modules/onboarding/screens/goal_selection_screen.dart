import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/goal_card_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/onboarding_progress_widget.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPad.h24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGap.h16,
              const OnboardingProgressWidget(current: 1, total: 2),
              AppGap.h32,
              Text(
                'What\'s your\nmain goal?',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              AppGap.h8,
              Text(
                'We\'ll tailor your meal plan around this.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              AppGap.h36,

              // Goal list
              Expanded(
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      itemCount: HealthGoal.values.length,
                      itemBuilder: (context, i) {
                        final goal = HealthGoal.values[i];
                        return GoalCardWidget(
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
              AppGap.h24,
            ],
          ),
        ),
      ),
    );
  }
}
