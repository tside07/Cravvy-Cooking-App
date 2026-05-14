import 'package:cravvy_cooking_app/init.dart';

class SettingsCardWidget extends StatelessWidget {
  final List<Widget> children;

  const SettingsCardWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(children: children),
    );
  }
}
