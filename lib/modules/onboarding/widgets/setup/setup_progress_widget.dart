import 'package:cravvy_cooking_app/init.dart';

class SetupProgressWidget extends StatelessWidget {
  final int current;
  final int total;

  const SetupProgressWidget({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $current of $total',
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((current / total) * 100).round()}%',
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppGap.h8,
          ClipRRect(
            borderRadius: AppBorderRadius.a4,
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
