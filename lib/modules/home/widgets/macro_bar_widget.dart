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
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            Text(
              '$current / $target$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
