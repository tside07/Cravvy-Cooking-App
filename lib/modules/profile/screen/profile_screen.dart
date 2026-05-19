import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/premium_banner_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_group_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/language_toggle_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_header_card_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_section_label_widget.dart';
import 'package:easy_localization/easy_localization.dart';

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
                      'profile.title'.tr(),
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

            ProfileSectionLabelWidget(label: 'profile.plan'.tr()),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: [
                  ('🎯', 'profile.edit_goal'.tr(), AppRouter.settings, false),
                  ('🥗', 'profile.food_pref'.tr(), AppRouter.settings, false),
                  (
                    '🚫',
                    'profile.diet_restriction'.tr(),
                    AppRouter.settings,
                    false,
                  ),
                ],
                onTap: (route) => context.push(route),
              ),
            ),

            ProfileSectionLabelWidget(label: 'profile.settings'.tr()),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: [
                  ('🔔', 'profile.reminders'.tr(), AppRouter.settings, false),
                  (
                    '💳',
                    'profile.subnplan'.tr(),
                    AppRouter.subscription,
                    false,
                  ),
                ],
                onTap: (route) => context.push(route),
              ),
            ),

            ProfileSectionLabelWidget(label: 'profile.data_privacy'.tr()),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: [
                  ('📤', 'profile.export'.tr(), '', false),
                  ('🗑️', 'profile.delete_acc'.tr(), '', false),
                ],
                onTap: (route) {
                  if (route == '__export') {
                    _showExportDialog(context);
                  } else if (route == '__delete') {
                    _showDeleteAccountDialog(context);
                  }
                },
                customRoutes: const {0: '__export', 1: '__delete'},
              ),
            ),

            ProfileSectionLabelWidget(label: 'profile.support'.tr()),
            SliverToBoxAdapter(
              child: SettingsGroupWidget(
                items: [
                  ('❓', 'profile.faq'.tr(), AppRouter.faq, false),
                  ('⭐', 'profile.rating'.tr(), '__rate', false),
                ],
                onTap: (route) {
                  if (route == '__rate') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('profile.redirect'.tr())),
                    );
                  } else {
                    context.push(route);
                  }
                },
              ),
            ),

            ProfileSectionLabelWidget(label: 'profile.interface'.tr()),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(left: 16, top: 14, right: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.a18,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SettingsTileWidget(
                      emoji: '🌙',
                      label: 'profile.darkmode'.tr(),
                      isToggle: true,
                      showDivider: true,
                      onTap: () {},
                    ),
                    const LanguageToggleTileWidget(showDivider: false),
                  ],
                ),
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
                          'profile.log_out'.tr(),
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
                  'profile.version'.tr(),
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
      title: Text('profile.export_title'.tr()),
      content: Text('profile.export_info'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(
            'profile.req_export'.tr(),
            style: const TextStyle(color: Colors.white),
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
      title: Text('profile.delete_acc_title'.tr()),
      content: Text('profile.del_dialog'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(
            'common.delete'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
