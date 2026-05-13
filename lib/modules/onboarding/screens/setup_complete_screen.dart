import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';

// SetupCompleteScreen không cần OnboardingArgs nữa —
// data đã lưu lên Supabase ở step 5 rồi
class SetupCompleteScreen extends StatefulWidget {
  const SetupCompleteScreen({super.key, this.args});

  // args có thể null khi đến từ setup flow
  final dynamic args;

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

    _scaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppPad.a24,
          child: Column(
            children: [
              const Spacer(),

              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🎉',
                      style: AppTextStyles.s20.copyWith(fontSize: 56),
                    ),
                  ),
                ),
              ),
              AppGap.h32,

              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      user != null
                          ? 'You\'re all set, ${user.fullName?.split(' ').first ?? ''}!'
                          : 'You\'re all set!',
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

                    // Summary card — dùng data thật từ Supabase
                    Container(
                      padding: AppPad.a20,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppBorderRadius.a20,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          if (user?.goal != null) ...[
                            _SummaryRow(
                              icon: '🎯',
                              label: 'Your goal',
                              value: _goalLabel(user!.goal!),
                            ),
                            const Divider(height: 24, color: AppColors.divider),
                          ],
                          _SummaryRow(
                            icon: '🌿',
                            label: 'Diet type',
                            value: user?.diets.isEmpty ?? true
                                ? 'No restrictions'
                                : user!.diets.take(3).join(', '),
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          _SummaryRow(
                            icon: '⏱',
                            label: 'Cooking time',
                            value: _cookingTimeLabel(user?.cookingTime),
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          const _SummaryRow(
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
                  label: 'View My Meal Plan',
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

  String _goalLabel(String goal) {
    switch (goal) {
      case 'lose-weight':
        return 'Lose Weight';
      case 'build-muscle':
        return 'Build Muscle';
      case 'maintain':
        return 'Maintain Weight';
      case 'health':
        return 'Manage Condition';
      default:
        return goal;
    }
  }

  String _cookingTimeLabel(String? time) {
    switch (time) {
      case 'quick':
        return 'Under 15 min';
      case 'short':
        return '15–30 min';
      case 'medium':
        return '30–60 min';
      case 'long':
        return '1 hour+';
      default:
        return 'Flexible';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
