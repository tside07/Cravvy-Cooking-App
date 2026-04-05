import 'package:cravvy_cooking_app/init.dart';

class StatCardWidget extends StatelessWidget {
  const StatCardWidget({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppPad.h10v14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppBorderRadius.a16,
        ),
        child: Column(
          children: [
            Text(emoji, style: AppTextStyles.s20.copyWith(fontSize: 22)),
            AppGap.h4,
            Text(
              value,
              style: AppTextStyles.s20.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
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
