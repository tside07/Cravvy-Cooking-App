import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/premium_banner_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_group_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_header_card_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_section_label_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.read<OnboardingProvider>().selectedGoal;
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 16, top: 16),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push(AppRouter.editProfile),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppBorderRadius.a12,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: ProfileHeaderCardWidget(profile: profile, goal: goal),
            ),

            const SliverToBoxAdapter(child: PremiumBannerWidget()),

            ProfileSectionLabelWidget(label: 'My Plan'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [
                  ('🎯', 'Edit Goal', false),
                  ('🥗', 'Food Preferences', false),
                  ('🚫', 'Dietary Restrictions', false),
                ],
                onTap: (label) => context.push(AppRouter.settings),
              ),
            ),

            ProfileSectionLabelWidget(label: 'Settings'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [
                  ('🔔', 'Reminders', false),
                  ('💳', 'Subscription & Plan', false),
                ],
                onTap: (label) {
                  switch (label) {
                    case 'Reminders':
                      context.push(AppRouter.settings);
                      break;
                    case 'Subscription & Plan':
                      context.push(AppRouter.subscription);
                      break;
                  }
                },
              ),
            ),

            ProfileSectionLabelWidget(label: 'Data & Privacy'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [
                  ('📤', 'Export Data', false),
                  ('🗑️', 'Delete Account', false),
                ],
                onTap: (label) {
                  switch (label) {
                    case 'Export Data':
                      _showExportDialog(context);
                      break;
                    case 'Delete Account':
                      _showDeleteAccountDialog(context);
                      break;
                  }
                },
              ),
            ),

            ProfileSectionLabelWidget(label: 'Support'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [
                  ('❓', 'FAQ', false),
                  ('⭐', 'Rate the App', false),
                ],
                onTap: (label) {
                  if (label == 'FAQ') {
                    context.push(AppRouter.faq);
                  } else if (label == 'Rate the App') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! Redirecting to store...'),
                      ),
                    );
                  }
                },
              ),
            ),

            ProfileSectionLabelWidget(label: 'Interface'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [('🌙', 'Dark Mode', true)],
                onTap: (_) {},
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: AppPad.h16v14,
                child: GestureDetector(
                  onTap: () => context.go(AppRouter.onboarding),
                  child: Container(
                    padding: AppPad.h16v14,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: AppBorderRadius.a16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        AppGap.w8,
                        Text(
                          'Log Out',
                          style: AppTextStyles.s14.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: AppPad.b20,
                child: Text(
                  'Cravvy v1.0.0',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s12.copyWith(color: AppColors.textHint),
                ),
              ),
            ),

            AppGap.sh100,
          ],
        ),
      ),
    );
  }
}

void _showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Export Data'),
      content: const Text(
        'Your data will be compiled and sent to your email address within 24 hours.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text(
            'Request Export',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Account ?'),
      content: const Text(
        'This action cannot be undone. All your data, meal plans, and progress will be permanently deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
