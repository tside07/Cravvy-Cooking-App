import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class ProfileHeaderCardWidget extends StatelessWidget {
  const ProfileHeaderCardWidget({super.key, required this.goal});

  final HealthGoal? goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        top: 20,
        right: 16,
      ),
      padding: AppPad.a20,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppBorderRadius.a24,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('👤', style: AppTextStyles.s20.copyWith(fontSize: 36)),
            ),
          ),
          AppGap.h12,
          Text(
            'Sarah Johnson',
            style: AppTextStyles.s20.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          Text(
            goal?.title ?? 'Healthy Eating',
            style: AppTextStyles.s12.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          AppGap.h20,
          Row(
            children: [
              _ProfileStat('BMI', '22.4', 'Normal'),
              _VSeparator(),
              _ProfileStat('Weight', '65kg', 'Current'),
              _VSeparator(),
              _ProfileStat('Streak', '7 🔥', 'Days'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.label, this.value, this.sub);

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.s18.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            sub,
            style: AppTextStyles.s10.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _VSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2));
}
