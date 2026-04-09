import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';

/// Instructions tab content – numbered step list.
class MealDetailInstructionsWidget extends StatelessWidget {
  const MealDetailInstructionsWidget({super.key, required this.meal});

  final Meal meal;

  static List<String> _mockSteps(String mealId) {
    switch (mealId) {
      case 'b1':
        return [
          'Toast the sourdough bread slices until golden and crispy.',
          'Halve the avocado, remove the pit and scoop the flesh into a bowl.',
          'Mash the avocado with lemon juice, salt and pepper to taste.',
          'Spread the mashed avocado evenly over the toasted bread.',
          'Bring a pot of water to a gentle simmer, add a splash of vinegar, then poach the eggs for 3 minutes.',
          'Top each toast with a poached egg, cherry tomatoes, and microgreens.',
          'Finish with a pinch of red pepper flakes and serve immediately.',
        ];
      case 'l1':
        return [
          'Season the chicken breast with salt, pepper, and a drizzle of olive oil.',
          'Grill the chicken on medium-high heat for 6–7 minutes per side until cooked through.',
          'Let the chicken rest for 5 minutes, then slice into strips.',
          'Combine the salad greens, cucumber, and red onion in a large bowl.',
          'Whisk together olive oil, lemon juice, and Dijon mustard to make the dressing.',
          'Drizzle the dressing over the salad and toss gently.',
          'Top with grilled chicken strips and crumbled feta cheese. Serve immediately.',
        ];
      default:
        return [
          'Preheat the oven to 200 °C (400 °F) and line a baking tray with parchment paper.',
          'Pat the salmon fillet dry with paper towels and place it on the tray.',
          'Season the salmon generously with salt, pepper, and minced garlic.',
          'Arrange the broccoli florets and cherry tomatoes around the salmon.',
          'Drizzle olive oil over everything and lay lemon slices on top of the salmon.',
          'Bake for 20–25 minutes until the salmon flakes easily with a fork.',
          'Garnish with fresh dill or parsley and serve hot.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _mockSteps(meal.id);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _StepCard(step: index + 1, text: steps[index]),
          ),
          childCount: steps.length,
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
