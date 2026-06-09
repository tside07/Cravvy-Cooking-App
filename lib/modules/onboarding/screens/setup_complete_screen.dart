import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';

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

  String _goalLabel(String goal) {
    switch (goal) {
      case 'lose-weight':
        return 'setup_complete.goal_lose'.tr();
      case 'build-muscle':
        return 'setup_complete.goal_muscle'.tr();
      case 'maintain':
        return 'setup_complete.goal_maintain'.tr();
      case 'health':
        return 'setup_complete.goal_health'.tr();
      default:
        return goal;
    }
  }

  String _cookingTimeLabel(String? time) {
    switch (time) {
      case 'quick':
        return 'setup_complete.time_quick'.tr();
      case 'short':
        return 'setup_complete.time_short'.tr();
      case 'medium':
        return 'setup_complete.time_medium'.tr();
      case 'long':
        return 'setup_complete.time_long'.tr();
      default:
        return 'setup_complete.time_flexible'.tr();
    }
  }

  String _dietLabel(String diet) {
    return switch (diet) {
      'Eat Clean' => 'onboarding_setup.diet_eat_clean'.tr(),
      'Low-Carb' => 'onboarding_setup.diet_low_carb'.tr(),
      'Keto' => 'onboarding_setup.diet_keto'.tr(),
      'Intermittent Fasting' => 'onboarding_setup.diet_intermittent_fasting'.tr(),
      'Vegetarian' => 'onboarding_setup.diet_vegetarian'.tr(),
      'Vegan' => 'onboarding_setup.diet_vegan'.tr(),
      'High-Protein' => 'onboarding_setup.diet_high_protein'.tr(),
      'Low-Sugar' => 'onboarding_setup.diet_low_sugar'.tr(),
      'Gluten-Free' => 'onboarding_setup.diet_gluten_free'.tr(),
      'No Specific Diet' => 'onboarding_setup.diet_no_specific'.tr(),
      _ => diet,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final firstName = user?.fullName?.split(' ').first ?? '';

    return PreAuthScaffold(
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
                      user != null && firstName.isNotEmpty
                          ? 'setup_complete.all_set_user'.tr(
                              namedArgs: {'name': firstName},
                            )
                          : 'setup_complete.all_set'.tr(),
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PreAuthTheme.textPrimary,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppGap.h12,
                    Text(
                      'setup_complete.personalized_desc'.tr(),
                      style: AppTextStyles.s15.copyWith(
                        color: PreAuthTheme.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppGap.h36,

                    // Summary card — dùng data thật từ Supabase
                    Container(
                      padding: AppPad.a20,
                      decoration: context.cardBox(radius: 20),
                      child: Column(
                        children: [
                          if (user?.goal != null) ...[
                            _SummaryRow(
                              icon: '🎯',
                              label: 'setup_complete.your_goal'.tr(),
                              value: _goalLabel(user!.goal!),
                            ),
                            const Divider(height: 24, color: AppColors.divider),
                          ],
                          _SummaryRow(
                            icon: '🌿',
                            label: 'setup_complete.diet_type'.tr(),
                            value: user?.diets.isEmpty ?? true
                                ? 'setup_complete.no_restrictions'.tr()
                                : user!.diets
                                    .take(3)
                                    .map(_dietLabel)
                                    .join(', '),
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          _SummaryRow(
                            icon: '⏱',
                            label: 'setup_complete.cooking_time'.tr(),
                            value: _cookingTimeLabel(user?.cookingTime),
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          _SummaryRow(
                            icon: '📅',
                            label: 'setup_complete.meal_plan'.tr(),
                            value: 'setup_complete.meal_plan_value'.tr(),
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
                  label: 'setup_complete.view_meal_plan'.tr(),
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
    final colors = context.appColors;
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
                style: context.themed(
                  AppTextStyles.s12,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                value,
                style: context.themed(
                  AppTextStyles.s14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
