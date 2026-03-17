import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/premium_banner.dart';
import '../widgets/settings_group.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _settingsGroups = [
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
    final goal = context.read<OnboardingProvider>().selectedGoal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: ProfileHeaderCard(goal: goal)),

            const SliverToBoxAdapter(child: PremiumBanner()),

            ..._settingsGroups.map(
              (items) => SliverToBoxAdapter(
                child: SettingsGroup(
                  items: items,
                  onTap: (label) {
                    if (label == 'Log Out') {
                      context.go(AppRouter.onboarding);
                    }
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
