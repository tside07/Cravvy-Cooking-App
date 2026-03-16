import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../providers/onboarding_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _settings = [
    [
      ('⚙️', 'Account Settings', false),
      ('🔔', 'Notifications', false),
      ('🌙', 'Dark Mode', true),
    ],
    [
      ('📊', 'My Goals', false),
      ('🥗', 'Diet Preferences', false),
      ('🏋️', 'Activity Level', false),
    ],
    [
      ('❓', 'Help & Support', false),
      ('⭐', 'Rate the App', false),
      ('🚪', 'Log Out', false),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    final goal = provider.selectedGoal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
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
                      width: 80, height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👤',
                            style: TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Sarah Johnson',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    Text(
                      goal?.title ?? 'Healthy Eating',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
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
              ),
            ),

            // Premium banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upgrade to Premium',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                          Text('Unlock AI meal planning & more',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Try Free',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
            ),

            // Settings groups
            ..._settings.asMap().entries.map((entry) {
              final items = entry.value;
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: List.generate(items.length, (i) {
                      final (emoji, label, isToggle) = items[i];
                      return _SettingsTile(
                        emoji: emoji,
                        label: label,
                        isToggle: isToggle,
                        showDivider: i < items.length - 1,
                        onTap: label == 'Log Out'
                            ? () => context.go(AppRouter.onboarding)
                            : () {},
                      );
                    }),
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _ProfileStat(this.label, this.value, this.sub);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          )),
          Text(sub, style: TextStyle(
            fontFamily: 'Nunito', fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          )),
        ],
      ),
    );
  }
}

class _VSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: Colors.white.withOpacity(0.2),
  );
}

class _SettingsTile extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isToggle;
  final bool showDivider;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.emoji,
    required this.label,
    required this.isToggle,
    required this.showDivider,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 2),
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(widget.emoji,
                    style: const TextStyle(fontSize: 18))),
          ),
          title: Text(widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: widget.label == 'Log Out'
                    ? AppColors.error
                    : AppColors.textPrimary,
              )),
          trailing: widget.isToggle
              ? Switch.adaptive(
                  value: _toggled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _toggled = v),
                )
              : Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
          onTap: widget.isToggle ? null : widget.onTap,
        ),
        if (widget.showDivider)
          const Divider(
              height: 1, indent: 68, endIndent: 16,
              color: AppColors.divider),
      ],
    );
  }
}
