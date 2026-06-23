import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';

import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/modules/dashboard/dashboard_scaffold_key.dart';

import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';

import 'package:easy_localization/easy_localization.dart';



/// Shared top bar for the 5 navbar screens.

class CustomAppBar extends StatelessWidget {

  const CustomAppBar({

    super.key,

    this.title,

    this.subtitle,

    this.greeting = false,

    this.trailing,

  });



  final String? title;

  final String? subtitle;

  final bool greeting;

  final Widget? trailing;



  String _greetingText() {

    final hour = DateTime.now().hour;

    if (hour < 12) return 'home.greeting_morning'.tr();

    if (hour < 17) return 'home.greeting_afternoon'.tr();

    return 'home.greeting_evening'.tr();

  }



  @override

  Widget build(BuildContext context) {

    final _ = context.locale;

    final appColors = context.appColors;

    final cartCount = context.watch<ShoppingListProvider>().totalCount;



    String headingText;

    String? subText;

    if (greeting) {

      final user = context.watch<AuthProvider>().user;

      final firstName =

          user?.fullName?.split(' ').first ?? 'home.default_name'.tr();

      headingText = '${_greetingText()}, $firstName';

      subText = 'home.welcome_tagline'.tr();

    } else {

      headingText = title ?? '';

      subText = subtitle;

    }



    return Padding(

      padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              _CircleIconButton(

                icon: Icons.menu_rounded,

                onTap: () => dashboardScaffoldKey.currentState?.openDrawer(),

              ),

              const Spacer(),

              _CircleIconButton(

                icon: Icons.shopping_bag_outlined,

                badgeCount: cartCount,

                onTap: () => context.push(AppRouter.shoppingList),

              ),

            ],

          ),

          AppGap.h16,

          Row(

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    if (headingText.isNotEmpty)

                      Text(

                        headingText,

                        style: AppTextStyles.s20.copyWith(

                          fontSize: greeting ? 26 : 24,

                          fontWeight: FontWeight.w800,

                          color: appColors.textPrimary,

                        ),

                      ),

                    if (subText != null && subText.isNotEmpty) ...[

                      AppGap.h2,

                      Text(

                        subText,

                        style: AppTextStyles.s14

                            .copyWith(color: appColors.textSecondary),

                      ),

                    ],

                  ],

                ),

              ),

              if (trailing != null) ...[

                AppGap.w12,

                trailing!,

              ],

            ],

          ),

        ],

      ),

    );

  }

}



class _CircleIconButton extends StatelessWidget {

  const _CircleIconButton({

    required this.icon,

    required this.onTap,

    this.badgeCount = 0,

  });



  final IconData icon;

  final VoidCallback onTap;

  final int badgeCount;



  @override

  Widget build(BuildContext context) {

    final appColors = context.appColors;



    return Stack(

      clipBehavior: Clip.none,

      children: [

        Pressable(

          onTap: onTap,

          child: Container(

            width: 44,

            height: 44,

            decoration: BoxDecoration(

              color: appColors.cardSurface,

              shape: BoxShape.circle,

              border: Border.all(color: appColors.borderDivider),

              boxShadow: AppShadows.e1Of(Theme.of(context).brightness),

            ),

            child: Icon(icon, size: 22, color: appColors.textPrimary),

          ),

        ),

        if (badgeCount > 0)

          Positioned(

            top: -2,

            right: -2,

            child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),

              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),

              decoration: BoxDecoration(

                color: AppColors.primary,

                borderRadius: BorderRadius.circular(10),

                border: Border.all(

                  color: appColors.backgroundMain,

                  width: 1.5,

                ),

              ),

              child: Text(

                badgeCount > 99 ? '99+' : '$badgeCount',

                textAlign: TextAlign.center,

                style: AppTextStyles.s10.copyWith(

                  color: appColors.onPrimary,

                  fontWeight: FontWeight.w700,

                ),

              ),

            ),

          ),

      ],

    );

  }

}


