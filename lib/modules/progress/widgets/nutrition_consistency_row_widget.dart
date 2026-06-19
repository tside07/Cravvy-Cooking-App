import 'package:cravvy_cooking_app/init.dart';

class NutritionConsistencyRowWidget extends StatelessWidget {
  const NutritionConsistencyRowWidget({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: context.themed(
              AppTextStyles.s13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppBorderRadius.a6,
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              backgroundColor: colors.elevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        AppGap.w10,
        Text(
          '$percent%',
          style: context.themed(AppTextStyles.s14, fontWeight: FontWeight.w700)
              .copyWith(color: color),
        ),
      ],
    );
  }
}
