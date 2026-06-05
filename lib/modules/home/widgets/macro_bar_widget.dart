import 'package:cravvy_cooking_app/init.dart';

class MacroBarWidget extends StatelessWidget {
  const MacroBarWidget({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final int current;
  final int target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            Text(
              '$current / $target$unit',
              style: context.themed(
                Theme.of(context).textTheme.bodySmall ??
                    AppTextStyles.s12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppGap.h4,
        ClipRRect(
          borderRadius: AppBorderRadius.a6,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: colors.elevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
