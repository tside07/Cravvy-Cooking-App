import 'package:cravvy_cooking_app/core/theme/theme_mode_provider.dart';

import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';

import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';

import 'package:easy_localization/easy_localization.dart';



/// App-wide navigation drawer (replaces the former Profile tab).

class AppDrawer extends StatelessWidget {

  const AppDrawer({super.key});



  void _go(BuildContext context, String route) {

    Navigator.pop(context);

    context.push(route);

  }



  @override

  Widget build(BuildContext context) {

    final _ = context.locale;

    final appColors = context.appColors;

    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final isPremium = auth.user?.isPremium ?? false;

    return Drawer(

      child: ColoredBox(

        color: appColors.backgroundMain,

        child: SafeArea(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Padding(

                padding: const EdgeInsets.only(left: 12, top: 8),

                child: IconButton(

                  icon: Icon(Icons.menu_open_rounded,

                      color: appColors.textPrimary),

                  onPressed: () => Navigator.pop(context),

                ),

              ),

              _DrawerHeader(
                profile: profile,
                isPremium: isPremium,
              ),

              AppGap.h12,

              Expanded(

                child: ListView(

                  padding: const EdgeInsets.symmetric(vertical: 4),

                  children: [

                    _DarkModeItem(),

                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'profile.account_info'.tr(),
                      onTap: () => _go(context, AppRouter.editProfile),
                    ),
                    _DrawerItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'profile.change_pw'.tr(),
                      onTap: () => _go(context, AppRouter.settings),
                    ),

                    _DrawerItem(

                      icon: Icons.workspace_premium_outlined,

                      label: 'profile.premium'.tr(),

                      onTap: () => _go(context, AppRouter.premium),

                    ),

                    _DrawerItem(

                      icon: Icons.settings_outlined,

                      label: 'profile.settings'.tr(),

                      onTap: () => _go(context, AppRouter.settings),

                    ),

                    _DrawerItem(

                      icon: Icons.help_outline_rounded,

                      label: 'profile.faq'.tr(),

                      onTap: () => _go(context, AppRouter.faq),

                    ),

                    _LanguageItem(),

                  ],

                ),

              ),

              Divider(height: 1, color: appColors.borderDivider),

              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'profile.log_out'.tr(),
                isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go(AppRouter.onboarding);
                  },
                ),

              AppGap.h8,

            ],

          ),

        ),

      ),

    );

  }

}



class _DrawerHeader extends StatelessWidget {

  const _DrawerHeader({
    required this.profile,
    required this.isPremium,
  });

  final ProfileProvider profile;

  final bool isPremium;



  @override

  Widget build(BuildContext context) {

    final appColors = context.appColors;



    return Container(

      width: double.infinity,

      margin: const EdgeInsets.symmetric(horizontal: 12),

      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),

      decoration: BoxDecoration(

        color: appColors.cardSurface,

        borderRadius: AppBorderRadius.a16,

      ),

      child: Row(

        children: [

          Container(

            width: 56,

            height: 56,

            decoration: const BoxDecoration(

              gradient: AppColors.primaryGradient,

              shape: BoxShape.circle,

            ),

            child: Center(

              child: Text(

                profile.initials,

                style: AppTextStyles.s20.copyWith(

                  fontWeight: FontWeight.w800,

                  color: appColors.onPrimary,

                ),

              ),

            ),

          ),

          AppGap.w12,

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  profile.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.s18.copyWith(

                    fontWeight: FontWeight.w800,

                    color: appColors.textPrimary,

                  ),

                ),

                AppGap.h2,

                Row(

                  children: [

                    Icon(

                      isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.check_circle_rounded,

                      size: 14,

                      color: isPremium
                          ? AppColors.primary
                          : AppColors.success,

                    ),

                    AppGap.w4,

                    Text(

                      isPremium
                          ? 'profile.plan_premium'.tr()
                          : 'profile.plan_free'.tr(),

                      style: AppTextStyles.s12.copyWith(

                        color: appColors.textSecondary,

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _DrawerItem extends StatelessWidget {

  const _DrawerItem({

    required this.icon,

    required this.label,

    required this.onTap,

    this.isDestructive = false,

  });



  final IconData icon;

  final String label;

  final VoidCallback onTap;

  final bool isDestructive;



  @override

  Widget build(BuildContext context) {

    final appColors = context.appColors;

    final color = isDestructive ? AppColors.error : appColors.textPrimary;

    return InkWell(

      onTap: onTap,

      child: Padding(

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        child: Row(

          children: [

            Icon(icon, size: 22, color: color),

            AppGap.w16,

            Text(

              label,

              style: AppTextStyles.s14.copyWith(

                fontWeight: FontWeight.w600,

                color: color,

              ),

            ),

          ],

        ),

      ),

    );

  }

}



class _DarkModeItem extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    final theme = context.watch<ThemeModeProvider>();

    final appColors = context.appColors;



    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),

      child: Row(

        children: [

          Icon(Icons.dark_mode_outlined,

              size: 22, color: appColors.textPrimary),

          AppGap.w16,

          Expanded(

            child: Text(

              'profile.darkmode'.tr(),

              style: AppTextStyles.s14.copyWith(

                fontWeight: FontWeight.w600,

                color: appColors.textPrimary,

              ),

            ),

          ),

          Switch.adaptive(

            value: theme.isDarkMode,

            onChanged: theme.setDarkMode,

          ),

        ],

      ),

    );

  }

}



class _LanguageItem extends StatelessWidget {

  static const _en = Locale('en', 'US');

  static const _vi = Locale('vi', 'VN');



  @override

  Widget build(BuildContext context) {

    final appColors = context.appColors;

    final isVi = context.locale.languageCode == 'vi';

    return InkWell(

      onTap: () => context.setLocale(isVi ? _en : _vi),

      child: Padding(

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        child: Row(

          children: [

            Icon(Icons.language_rounded,

                size: 22, color: appColors.textPrimary),

            AppGap.w16,

            Expanded(

              child: Text(

                'profile.language'.tr(),

                style: AppTextStyles.s14.copyWith(

                  fontWeight: FontWeight.w600,

                  color: appColors.textPrimary,

                ),

              ),

            ),

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

              decoration: BoxDecoration(

                color: appColors.chipSelectedBg,

                borderRadius: AppBorderRadius.a20,

                border: Border.all(color: appColors.chipSelectedBorder),

              ),

              child: Text(

                isVi ? '🇻🇳 VI' : '🇺🇸 EN',

                style: AppTextStyles.s12.copyWith(

                  fontWeight: FontWeight.w700,

                  color: AppColors.primary,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}


