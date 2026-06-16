import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final period = isAnnual ? 'premium.period_year'.tr() : 'premium.period_month'.tr();

    return AnimatedSwitcher(
      duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(isAnnual),
        width: double.infinity,
        padding: AppPad.a20,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: AppBorderRadius.card,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: isAnnual
            ? _buildAnnualLayout(context, price, period)
            : _buildMonthlyLayout(context, price, period),
      ),
    );
  }

  Widget _buildAnnualLayout(BuildContext context, int price, String period) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatVND(price)}đ',
              style: AppTextStyles.display.copyWith(
                fontSize: 28,
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            AppGap.w4,
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                period,
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
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
                'premium.save_badge'.tr(namedArgs: {'pct': '$savePct'}),
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
          'premium.annual_detail'.tr(namedArgs: {
            'monthly': _formatVND(annualMonthly),
            'savings': _formatVND(annualSavings),
          }),
          style: context.themed(
            AppTextStyles.s12,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyLayout(BuildContext context, int price, String period) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatVND(price)}đ',
              style: AppTextStyles.display.copyWith(
                fontSize: 28,
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            AppGap.w4,
            Padding(
              padding: AppPad.b4,
              child: Text(
                period,
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppGap.h8,
        Text(
          'premium.billed_monthly'.tr(),
          style: context.themed(
            AppTextStyles.s12,
            color: colors.textSecondary,
          ),
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
