import "package:cravvy_cooking_app/init.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';

class _Action {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  /// Dashboard tab index to switch to when tapped.
  final int? tabIndex;

  /// Route to push when tapped (takes precedence over [tabIndex]).
  final String? route;
  const _Action(
    this.icon,
    this.label,
    this.bgColor,
    this.iconColor, {
    this.tabIndex,
    this.route,
  });
}

class QuickActionsGridWidget extends StatelessWidget {
  const QuickActionsGridWidget({super.key});

  List<_Action> _actions(AppColorExtension colors) => [
        _Action(
          Icons.eco_rounded,
          'home.action_ingredients'.tr(),
          AppColors.primaryLight,
          AppColors.primary,
          tabIndex: 2,
        ),
        _Action(
          Icons.bolt_rounded,
          'home.action_quick'.tr(),
          AppColors.secondaryLight,
          AppColors.secondary,
          tabIndex: 2,
        ),
        _Action(
          Icons.calendar_today_rounded,
          'home.action_plan'.tr(),
          colors.elevated,
          AppColors.dinner,
          tabIndex: 1,
        ),
        _Action(
          Icons.smart_toy_rounded,
          'home.action_ai'.tr(),
          AppColors.warningLight,
          AppColors.warning,
          route: AppRouter.chat,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 8,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppPad.l8,
            child: Text(
              'home.quick_actions'.tr(),
              style: context.themed(AppTextStyles.h2),
            ),
          ),
          AppGap.h14,
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _actions(colors)
                .map((a) => _ActionCard(action: a))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _Action action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      borderRadius: AppBorderRadius.a18,
      child: InkWell(
        borderRadius: AppBorderRadius.a18,
        onTap: () {
          if (action.route != null) {
            context.push(action.route!);
          } else if (action.tabIndex != null) {
            context.read<DashboardTabProvider>().switchTo(action.tabIndex!);
          }
        },
        child: Container(
          padding: AppPad.a14,
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderDivider),
            borderRadius: AppBorderRadius.a18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  borderRadius: AppBorderRadius.a10,
                ),
                child: Center(
                  child: Icon(
                    action.icon,
                    color: action.iconColor,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                action.label,
                style: context.themed(
                  AppTextStyles.s12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
