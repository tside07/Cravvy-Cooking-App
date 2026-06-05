import 'package:cravvy_cooking_app/init.dart';

class SettingsCardWidget extends StatelessWidget {
  final List<Widget> children;

  const SettingsCardWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: appColors.cardSurface,
        borderRadius: AppBorderRadius.a16,
        border: isDark ? Border.all(color: appColors.borderDivider) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}
