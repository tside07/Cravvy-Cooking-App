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

  Widget _cell(BuildContext context, String val, bool check, bool isPremium) {
    final colors = context.appColors;
    if (val.isNotEmpty) {
      return Text(
        val,
        textAlign: TextAlign.center,
        style: AppTextStyles.s12.copyWith(
          color: isPremium ? AppColors.primary : colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Icon(
      check ? Icons.check_circle_rounded : Icons.cancel_rounded,
      size: 18,
      color: check
          ? (isPremium ? AppColors.primary : colors.textDisabled)
          : colors.borderDivider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                  style: context.themed(AppTextStyles.s14),
                ),
              ),
              Expanded(
                child: Center(
                  child: _cell(context, row.freeVal, row.freeCheck, false),
                ),
              ),
              Expanded(
                child: Center(
                  child: _cell(
                    context,
                    row.premiumVal,
                    row.premiumCheck,
                    true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 16, color: colors.borderDivider),
      ],
    );
  }
}
