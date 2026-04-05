import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';

class OnboardingProgressWidget extends StatelessWidget {
  const OnboardingProgressWidget({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step $current of $total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(AppRouter.mealPlan),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Skip setup'),
            ),
          ],
        ),
        AppGap.h8,
        ClipRRect(
          borderRadius: AppBorderRadius.a4,
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
