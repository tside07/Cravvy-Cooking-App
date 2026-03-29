import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_header_card_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/premium_banner_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_group_widget.dart';


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
            SliverToBoxAdapter(child: ProfileHeaderCardWidget(goal: goal)),

            const SliverToBoxAdapter(child: PremiumBannerWidget()),

            ..._settingsGroups.map(
              (items) => SliverToBoxAdapter(
                child: SettingsGroupWidget(
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
