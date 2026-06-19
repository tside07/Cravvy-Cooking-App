import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/premium/model/comp_row.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumComparisonTableWidget extends StatelessWidget {
  final List<CompRow> rows;

  const PremiumComparisonTableWidget({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: context.cardBox(),
      child: Column(
        children: [
          _buildHeader(context),
          Divider(height: 1, color: colors.borderDivider),
          ...rows.map((row) => _buildTableRow(context, row)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: AppPad.h16v14,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'subscription.table.feature'.tr(),
              style: context.themed(
                AppTextStyles.s14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'subscription.table.free'.tr(),
              textAlign: TextAlign.center,
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'subscription.table.premium'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, CompRow row) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderDivider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              row.feature,
              style: context.themed(
                AppTextStyles.s12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.free,
              textAlign: TextAlign.center,
              style: context.themed(
                AppTextStyles.s12,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.premium,
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
