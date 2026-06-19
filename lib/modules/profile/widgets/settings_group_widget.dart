import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/settings_tile_widget.dart';

class SettingsGroupWidget extends StatelessWidget {
  const SettingsGroupWidget({
    super.key,
    required this.items,
    required this.onTap,
    this.customRoutes,
  });

  /// Each item: (emoji, label, route, isToggle)
  final List<(String, String, String, bool)> items;
  final void Function(String route) onTap;

  /// Override route for specific indexes (e.g. dialog actions)
  final Map<int, String>? customRoutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 14, right: 16),
      decoration: context.cardBox(radius: 18),
      child: Column(
        children: List.generate(items.length, (i) {
          final (emoji, label, route, isToggle) = items[i];
          final resolvedRoute = customRoutes?[i] ?? route;
          return SettingsTileWidget(
            emoji: emoji,
            label: label,
            isToggle: isToggle,
            showDivider: i < items.length - 1,
            onTap: () => onTap(resolvedRoute),
          );
        }),
      ),
    );
  }
}
