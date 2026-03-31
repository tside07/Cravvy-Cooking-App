import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.read<OnboardingProvider>().selectedGoal;
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        top: 20,
        right: 24,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning !',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                AppGap.h2,
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
            padding: AppPad.h12v6,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppBorderRadius.a20,
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                AppGap.w4,
                Text(
                  '7-day streak',
                  style: AppTextStyles.s12.copyWith(
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
