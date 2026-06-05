import 'package:cravvy_cooking_app/init.dart';

class SettingsTileDividerWidget extends StatelessWidget {
  const SettingsTileDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 56, color: context.appColors.borderDivider);
  }
}
