import 'package:cravvy_cooking_app/init.dart';

class PremiumPriceCardWidget extends StatelessWidget {
  final bool isAnnual;
  final int annualPrice;
  final int monthlyPrice;
  final int annualMonthly;
  final int annualSavings;
  final int savePct;

  const PremiumPriceCardWidget({
    super.key,
    required this.isAnnual,
    required this.annualPrice,
    required this.monthlyPrice,
    required this.annualMonthly,
    required this.annualSavings,
    required this.savePct,
  });

  @override
  Widget build(BuildContext context) {
    final price = isAnnual ? annualPrice : monthlyPrice;
    final period = isAnnual ? '/year' : '/month';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(isAnnual),
        width: double.infinity,
        padding: AppPad.a20,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: AppBorderRadius.a16,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: isAnnual
            ? _buildAnnualLayout(price, period)
            : _buildMonthlyLayout(price, period),
      ),
    );
  }

  Widget _buildAnnualLayout(int price, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatVND(price)}đ',
              style: AppTextStyles.s20.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            AppGap.w4,
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                period,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppGap.w8,
            // Save % badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Text(
                'Save\n$savePct%',
                textAlign: TextAlign.center,
                style: AppTextStyles.s10.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  fontSize: 9,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        AppGap.h8,
        Text(
          'Only ${_formatVND(annualMonthly)}đ/month • Save up to ${_formatVND(annualSavings)}đ per year',
          style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthlyLayout(int price, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatVND(price)}đ',
              style: AppTextStyles.s20.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            AppGap.w4,
            Padding(
              padding: AppPad.b4,
              child: Text(
                period,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppGap.h8,
        Text(
          'Billed monthly',
          style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _formatVND(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
