import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:cravvy_cooking_app/core/theme/theme_mode_provider.dart';
import 'package:cravvy_cooking_app/modules/settings/provider/settings_provider.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_card_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_delete_confirm_card_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_nav_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_premium_banner_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_section_title_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_switch_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/settings/widgets/settings_tile_divider_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ─── Dialogs ────────────────────────────────────────────────────────────────
  // Dialog logic giữ trong screen vì nó cần BuildContext để show dialog
  // và không có state nào cần lưu lại sau khi dialog đóng.

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a20),
        title: Text('settings.export_dialog_title'.tr()),
        content: Text('settings.export_dialog_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'settings.export_confirm'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    context.read<SettingsProvider>().hideDeleteConfirmCard();
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    if (!context.mounted) return;
    if (ok) {
      context.go(AppRouter.onboarding);
      return;
    }
    final msg = auth.errorMessage ?? 'settings.delete_failed'.tr();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a20),
        title: Text('settings.sign_out_dialog_title'.tr()),
        content: Text('settings.sign_out_dialog_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go(AppRouter.onboarding);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'settings.sign_out_confirm'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    // ChangeNotifierProvider đặt ở đây vì SettingsProvider chỉ cần
    // tồn tại trong phạm vi màn hình này, không cần share lên toàn app.
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: BoxDecoration(
        color: appColors.cardSurface,
        border: Border(bottom: BorderSide(color: appColors.borderDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: appColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Text(
            'settings.title'.tr(),
            style: AppTextStyles.s18.copyWith(
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: AppPad.a16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumBanner(context),
          AppGap.h20,
          _buildNotificationsSection(context),
          AppGap.h20,
          _buildAppearanceSection(context),
          AppGap.h20,
          _buildAccountSection(context),
          AppGap.h20,
          _buildLegalSection(context),
          AppGap.h20,
          _buildDangerZoneSection(context),
          AppGap.h32,
          _buildVersionText(context),
          AppGap.h16,
        ],
      ),
    );
  }

  // ─── Sections ────────────────────────────────────────────────────────────────

  Widget _buildPremiumBanner(BuildContext context) {
    return SettingsPremiumBannerWidget(
      onTap: () => context.push(AppRouter.premium),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitleWidget(
          title: 'settings.section_notifications'.tr(),
        ),
        AppGap.h8,
        // Consumer chỉ bao widget nào thực sự cần đọc state
        // → tránh rebuild toàn bộ màn hình khi toggle switch
        Consumer<SettingsProvider>(
          builder: (context, provider, _) => SettingsCardWidget(
            children: [
              SettingsSwitchTileWidget(
                icon: Icons.restaurant_menu_outlined,
                iconColor: AppColors.primary,
                title: 'settings.meal_reminder'.tr(),
                subtitle: 'settings.meal_reminder_sub'.tr(),
                value: provider.mealReminder,
                onChanged: provider.setMealReminder,
              ),
              const SettingsTileDividerWidget(),
              SettingsSwitchTileWidget(
                icon: Icons.auto_awesome_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'settings.daily_suggestion'.tr(),
                subtitle: 'settings.daily_suggestion_sub'.tr(),
                value: provider.dailySuggestion,
                onChanged: provider.setDailySuggestion,
              ),
              const SettingsTileDividerWidget(),
              SettingsSwitchTileWidget(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF3B82F6),
                title: 'settings.water_reminder'.tr(),
                subtitle: 'settings.water_reminder_sub'.tr(),
                value: provider.waterReminder,
                onChanged: provider.setWaterReminder,
              ),
              const SettingsTileDividerWidget(),
              SettingsSwitchTileWidget(
                icon: Icons.campaign_outlined,
                iconColor: AppColors.warning,
                title: 'settings.news_updates'.tr(),
                subtitle: 'settings.news_updates_sub'.tr(),
                value: provider.newsUpdates,
                onChanged: provider.setNewsUpdates,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final currentLang = 'settings.language_current'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitleWidget(title: 'settings.section_appearance'.tr()),
        AppGap.h8,
        Consumer<ThemeModeProvider>(
          builder: (context, theme, _) => SettingsCardWidget(
            children: [
              SettingsSwitchTileWidget(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF64748B),
                title: 'settings.dark_mode'.tr(),
                subtitle: 'settings.dark_mode_sub'.tr(),
                value: theme.isDarkMode,
                onChanged: theme.setDarkMode,
              ),
              const SettingsTileDividerWidget(),
              SettingsNavTileWidget(
                icon: Icons.language_outlined,
                iconColor: AppColors.secondary,
                title: 'settings.language'.tr(),
                trailing: currentLang,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitleWidget(title: 'settings.section_account'.tr()),
        AppGap.h8,
        SettingsCardWidget(
          children: [
            SettingsNavTileWidget(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              title: 'settings.edit_profile'.tr(),
              onTap: () => context.push(AppRouter.editProfile),
            ),
            const SettingsTileDividerWidget(),
            SettingsNavTileWidget(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF6366F1),
              title: 'settings.change_password'.tr(),
              onTap: () => context.push(AppRouter.forgotPassword),
            ),
            const SettingsTileDividerWidget(),
            SettingsNavTileWidget(
              icon: Icons.download_outlined,
              iconColor: AppColors.secondary,
              title: 'settings.export_data'.tr(),
              onTap: () => _showExportDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitleWidget(title: 'settings.section_legal'.tr()),
        AppGap.h8,
        SettingsCardWidget(
          children: [
            SettingsNavTileWidget(
              icon: Icons.help_outline_rounded,
              iconColor: AppColors.primary,
              title: 'settings.faq'.tr(),
              onTap: () => context.push(AppRouter.faq),
            ),
            const SettingsTileDividerWidget(),
            SettingsNavTileWidget(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'settings.privacy_policy'.tr(),
              onTap: () => context.push(AppRouter.privacyPolicy),
            ),
            const SettingsTileDividerWidget(),
            SettingsNavTileWidget(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: 'settings.terms'.tr(),
              onTap: () => context.push(AppRouter.termsOfService),
            ),
            const SettingsTileDividerWidget(),
            SettingsNavTileWidget(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.warning,
              title: 'settings.disclaimer'.tr(),
              onTap: () => context.push(AppRouter.disclaimer),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) => Column(
        children: [
          SettingsCardWidget(
            children: [
              SettingsNavTileWidget(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                title: 'settings.sign_out'.tr(),
                titleColor: AppColors.error,
                onTap: () => _showSignOutDialog(context),
              ),
              const SettingsTileDividerWidget(),
              SettingsNavTileWidget(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.error,
                title: 'settings.delete_acc'.tr(),
                titleColor: AppColors.error,
                onTap: provider.showDeleteConfirmCard,
              ),
            ],
          ),
          if (provider.showDeleteConfirm) ...[
            AppGap.h12,
            SettingsDeleteConfirmCardWidget(
              onCancel: provider.hideDeleteConfirmCard,
              onConfirm: () => _confirmDeleteAccount(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersionText(BuildContext context) {
    return Center(
      child: Text(
        'settings.version'.tr(),
        style: AppTextStyles.s12.copyWith(
          color: context.appColors.textDisabled,
        ),
      ),
    );
  }
}
