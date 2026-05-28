import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/feature_row.dart';

class FeatureRowTileWidget extends StatelessWidget {
  const FeatureRowTileWidget({
    super.key,
    required this.row,
    required this.isLast,
  });

  final FeatureRow row;
  final bool isLast;

  Widget _cell(String val, bool check, bool isPremium) {
    if (val.isNotEmpty) {
      return Text(
        val,
        textAlign: TextAlign.center,
        style: AppTextStyles.s12.copyWith(
          color: isPremium ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Icon(
      check ? Icons.check_circle_rounded : Icons.cancel_rounded,
      size: 18,
      color: check
          ? (isPremium ? AppColors.primary : AppColors.textHint)
          : AppColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppPad.h16v12,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  row.label,
                  style: AppTextStyles.s14.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Center(child: _cell(row.freeVal, row.freeCheck, false)),
              ),
              Expanded(
                child: Center(
                  child: _cell(row.premiumVal, row.premiumCheck, true),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 16, color: AppColors.border),
      ],
    );
  }
}
