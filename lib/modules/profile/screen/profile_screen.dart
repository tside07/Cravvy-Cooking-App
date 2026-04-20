import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/premium_banner_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_group_widget.dart';

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
              child: _ProfileHeaderCard(profile: profile, goal: goal),
            ),

            const SliverToBoxAdapter(child: PremiumBannerWidget()),

            _SectionLabel(label: 'My Plan'),
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

            _SectionLabel(label: 'Settings'),
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

            _SectionLabel(label: 'Data & Privacy'),
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

            _SectionLabel(label: 'Support'),
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
                      const SnackBar(content: Text('Thank you! Redirecting to store...')),
                    );
                  }
                },
              ),
            ),

            _SectionLabel(label: 'Interface'),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: const [
                  ('🌙', 'Dark Mode', true),
                ],
                onTap: (_) {},
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.goal});

  final ProfileProvider profile;
  final HealthGoal? goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 20, right: 16),
      padding: AppPad.a20,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a24,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack15,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: AppTextStyles.s20.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          AppGap.h12,

          Text(
            profile.name,
            style: AppTextStyles.s20.copyWith(fontWeight: FontWeight.w800),
          ),
          AppGap.h4,

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 14, color: AppColors.textSecondary),
              AppGap.w4,
              Text(
                profile.email,
                style: AppTextStyles.s12
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          AppGap.h4,

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.textSecondary),
              AppGap.w4,
              Text(
                profile.phone,
                style: AppTextStyles.s12
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          AppGap.h8,

          if (profile.bio.isNotEmpty) ...[
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
            ),
            AppGap.h10,
          ],

          if (goal != null)
            Container(
              padding: AppPad.h12v6,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorderRadius.a20,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_rounded,
                      size: 14, color: AppColors.primary),
                  AppGap.w4,
                  Text(
                    goal!.title,
                    style: AppTextStyles.s12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          AppGap.h16,

          Container(
            padding: AppPad.a12,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppBorderRadius.a16,
            ),
            child: Row(
              children: [
                _StatBox(label: 'Age', value: '${profile.age}'),
                _VSep(),
                _StatBox(
                    label: 'Height', value: '${profile.heightCm}cm'),
                _VSep(),
                _StatBox(
                    label: 'Weight',
                    value: '${profile.weightKg.toStringAsFixed(0)}kg'),
              ],
            ),
          ),
          AppGap.h10,

          Container(
            width: double.infinity,
            padding: AppPad.h16v10,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppBorderRadius.a12,
            ),
            child: Text(
              'BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiLabel})',
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppGap.h12,

          GestureDetector(
            onTap: () => context.push(AppRouter.editProfile),
            child: Container(
              width: double.infinity,
              padding: AppPad.h16v12,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppBorderRadius.a12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.primary),
                  AppGap.w8,
                  Text(
                    'Edit personal info',
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.s10.copyWith(color: AppColors.textSecondary),
          ),
          AppGap.h2,
          Text(
            value,
            style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}

class _SectionLabel extends SliverToBoxAdapter {
  _SectionLabel({required String label})
      : super(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 4),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        );
}

void _showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Export Data'),
      content: const Text(
          'Your data will be compiled and sent to your email address within 24 hours.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Request Export',
              style: TextStyle(color: Colors.white)),
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
      title: const Text('Delete Account?'),
      content: const Text(
          'This action cannot be undone. All your data, meal plans, and progress will be permanently deleted.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

