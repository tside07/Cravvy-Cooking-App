import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class _Action {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color iconColor;
  const _Action(this.emoji, this.label, this.bgColor, this.iconColor);
}

const _kActions = [
  _Action('🥕', 'Ingredients I have', AppColors.primaryLight, AppColors.primary),
  _Action('⚡', 'Quick recipes', AppColors.secondaryLight, AppColors.secondary),
  _Action('📋', "Today's full plan", Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  _Action('🤖', 'Ask AI Chef', AppColors.warningLight, AppColors.warning),
];

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 14),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(action.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const Spacer(),
              Text(
                action.label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
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
