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
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
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
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 36)),
            ),
          ),
          AppGap.h12,
          const Text(
            'Sarah Johnson',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            goal?.title ?? 'Healthy Eating',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
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
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
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
