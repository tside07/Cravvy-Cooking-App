import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_tile_widget.dart';

class SettingsGroupWidget extends StatelessWidget {
  const SettingsGroupWidget({
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
      margin: const EdgeInsets.only(
        left: 16,
        top: 14,
        right: 16,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a18,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final (emoji, label, isToggle) = items[i];
          return SettingsTileWidget(
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
