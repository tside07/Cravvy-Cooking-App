import 'package:cravvy_cooking_app/init.dart';

class SettingsNavTileWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final Color? titleColor;
  final VoidCallback onTap;

  const SettingsNavTileWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.a16,
      child: Padding(
        padding: AppPad.h16v14,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.a10,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            AppGap.w12,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? appColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: AppTextStyles.s12.copyWith(
                  color: appColors.textSecondary,
                ),
              ),
              AppGap.w4,
            ],
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: appColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
