import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'settings_tile.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.items,
    required this.onTap,
  });

  /// Each item: (emoji, label, isToggle)
  final List<(String, String, bool)> items;
  final void Function(String label) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final (emoji, label, isToggle) = items[i];
          return SettingsTile(
            emoji: emoji,
            label: label,
            isToggle: isToggle,
            showDivider: i < items.length - 1,
            onTap: () => onTap(label),
          );
        }),
      ),
    );
  }
}
