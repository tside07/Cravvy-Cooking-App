import "package:cravvy_cooking_app/init.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';

class _Action {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color iconColor;

  /// Dashboard tab index to switch to when tapped.
  final int? tabIndex;
  const _Action(
    this.emoji,
    this.label,
    this.bgColor,
    this.iconColor, {
    this.tabIndex,
  });
}

class QuickActionsGridWidget extends StatelessWidget {
  const QuickActionsGridWidget({super.key});

  List<_Action> _actions(AppColorExtension colors) => [
        _Action(
          '🥕',
          'home.action_ingredients'.tr(),
          AppColors.primaryLight,
          AppColors.primary,
          tabIndex: 2,
        ),
        _Action(
          '⚡',
          'home.action_quick'.tr(),
          AppColors.secondaryLight,
          AppColors.secondary,
          tabIndex: 2,
        ),
        _Action(
          '📋',
          'home.action_plan'.tr(),
          colors.elevated,
          AppColors.dinner,
          tabIndex: 1,
        ),
        _Action(
          '🤖',
          'home.action_ai'.tr(),
          AppColors.warningLight,
          AppColors.warning,
          tabIndex: 2,
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
              style: Theme.of(context).textTheme.headlineSmall,
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
          if (action.tabIndex != null) {
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
                  child: Text(
                    action.emoji,
                    style: AppTextStyles.s18,
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
