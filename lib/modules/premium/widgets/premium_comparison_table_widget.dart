import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/premium/model/comp_row.dart';

class PremiumComparisonTableWidget extends StatelessWidget {
  final List<CompRow> rows;

  const PremiumComparisonTableWidget({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.border),
          ...rows.map((row) => _buildTableRow(row)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppPad.h16v14,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'Feature',
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Free',
              textAlign: TextAlign.center,
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Premium',
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

  Widget _buildTableRow(CompRow row) {
    return Container(
      padding: AppPad.h16v12,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              row.feature,
              style: AppTextStyles.s12.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.free,
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
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
