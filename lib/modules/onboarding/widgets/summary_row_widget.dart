import 'package:cravvy_cooking_app/init.dart';

class SummaryRowWidget extends StatelessWidget {
  const SummaryRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Text(icon, style: AppTextStyles.s20),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                value,
                style: context.themed(
                  AppTextStyles.s16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
