import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.goal});

  final HealthGoal? goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
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
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: Colors.white.withOpacity(0.2),
      );
}
