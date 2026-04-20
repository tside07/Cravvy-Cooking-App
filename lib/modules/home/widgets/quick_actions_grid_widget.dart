import "package:cravvy_cooking_app/init.dart";
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';

class _Action {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color iconColor;
  /// Dashboard tab index to switch to when tapped.
  final int? tabIndex;
  const _Action(this.emoji, this.label, this.bgColor, this.iconColor, {this.tabIndex});
}

const _kActions = [
  _Action(
    '🥕',
    'Ingredients I have',
    AppColors.primaryLight,
    AppColors.primary,
    tabIndex: 2, // Search tab
  ),
  _Action('⚡', 'Quick recipes', AppColors.secondaryLight, AppColors.secondary,
    tabIndex: 2, // Search tab
  ),
  _Action('📋', "Today's full plan", Color(0xFFEDE9FE), Color(0xFF7C3AED),
    tabIndex: 1, // Meal Plan tab
  ),
  _Action('🤖', 'Ask AI Chef', AppColors.warningLight, AppColors.warning,
    tabIndex: 2, // Search tab
  ),
];

class QuickActionsGridWidget extends StatelessWidget {
  const QuickActionsGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 24,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppPad.l8,
            child: Text(
              'Quick Actions',
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
            children: _kActions.map((a) => _ActionCard(action: a)).toList(),
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
    return Material(
      color: AppColors.surface,
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
            border: Border.all(color: AppColors.border),
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
                style: AppTextStyles.s12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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

