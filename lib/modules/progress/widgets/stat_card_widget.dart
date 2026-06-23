import 'package:cravvy_cooking_app/init.dart';

class StatCardWidget extends StatelessWidget {
  const StatCardWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // The pastel [color] background stays light in both themes, so the dark
    // value / muted label colors are intentionally fixed (not theme-aware).
    return Expanded(
      child: Container(
        padding: AppPad.h10v14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppBorderRadius.a16,
          boxShadow: AppShadows.e1Of(Theme.of(context).brightness),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            AppGap.h4,
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: AppTextStyles.s10.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
