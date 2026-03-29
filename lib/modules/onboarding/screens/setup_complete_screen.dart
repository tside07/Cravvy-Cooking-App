import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/summary_row_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class SetupCompleteScreen extends StatefulWidget {
  const SetupCompleteScreen({super.key, required this.args});

  final OnboardingArgs args;

  @override
  State<SetupCompleteScreen> createState() => _SetupCompleteScreenState();
}

class _SetupCompleteScreenState extends State<SetupCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.args.goal;
    final diets = widget.args.diets;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppPad.a24,
          child: Column(
            children: [
              const Spacer(),

              // Celebration icon
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 56)),
                  ),
                ),
              ),
              AppGap.h32,

              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      'You\'re all set!',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    AppGap.h12,
                    Text(
                      'Your personalized meal plan is ready.\nLet\'s start eating better today!',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    AppGap.h36,

                    // Summary card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          if (goal != null) ...[
                            SummaryRowWidget(
                              icon: '🎯',
                              label: 'Your goal',
                              value: goal.title,
                            ),
                            const Divider(
                              height: 24,
                              color: AppColors.divider,
                            ),
                          ],
                          SummaryRowWidget(
                            icon: '🌿',
                            label: 'Diet type',
                            value: diets.isEmpty
                                ? 'No restrictions'
                                : diets.map((d) => d.label).join(', '),
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          const SummaryRowWidget(
                            icon: '📅',
                            label: 'Meal plan',
                            value: '7-day plan ready',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              FadeTransition(
                opacity: _fadeAnim,
                child: CravvyButton(
                  label: 'View My Meal Plan 🍽️',
                  onTap: () => context.go(AppRouter.app),
                ),
              ),
              AppGap.h12,
            ],
          ),
        ),
      ),
    );
  }
}
