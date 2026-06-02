import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/dashboard/dashboard_scaffold_key.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shared top bar for the 5 navbar screens.
///
/// Top row: profile (left, switches to Profile tab) + cart (right, opens the
/// shopping list with an item-count badge). Below it shows either a localized
/// greeting (Home) or a per-screen [title]/[subtitle]. An optional [trailing]
/// widget sits next to the title for screen-specific controls.
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.greeting = false,
    this.trailing,
  });

  /// Main heading text. Ignored when [greeting] is true.
  final String? title;

  /// Secondary text under the title.
  final String? subtitle;

  /// When true, renders "greeting, <name> 👋" + welcome tagline (Home).
  final bool greeting;

  /// Optional control rendered to the right of the title (e.g. edit button).
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
    final cartCount = context.watch<ShoppingListProvider>().totalCount;

    String headingText;
    String? subText;
    if (greeting) {
      final user = context.watch<AuthProvider>().user;
      final firstName =
          user?.fullName?.split(' ').first ?? 'home.default_name'.tr();
      headingText = '${_greetingText()}, $firstName 👋';
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                    if (subText != null && subText.isNotEmpty) ...[
                      AppGap.h2,
                      Text(
                        subText,
                        style: AppTextStyles.s14
                            .copyWith(color: AppColors.textSecondary),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 22, color: AppColors.textPrimary),
            ),
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
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: AppTextStyles.s10.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
