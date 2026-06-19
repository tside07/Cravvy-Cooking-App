import 'package:cravvy_cooking_app/init.dart';

class SettingsSectionTitleWidget extends StatelessWidget {
  final String title;

  const SettingsSectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPad.l4,
      child: Text(
        title,
        style: AppTextStyles.s12.copyWith(
          color: context.appColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
