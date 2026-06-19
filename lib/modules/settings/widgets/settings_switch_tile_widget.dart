import 'package:cravvy_cooking_app/init.dart';

class SettingsSwitchTileWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTileWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: AppPad.h16v12,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.chip,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.s12.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
