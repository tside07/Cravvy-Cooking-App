import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class PlanToggleWidget extends StatelessWidget {
  final bool isAnnual;
  final int savePct;
  final ValueChanged<bool> onChanged;

  const PlanToggleWidget({
    super.key,
    required this.isAnnual,
    required this.savePct,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('premium.monthly'.tr(), !isAnnual, () => onChanged(false)),
        AppGap.w8,
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildTab('premium.annual'.tr(), isAnnual, () => onChanged(true)),
            // "Save X%" badge
            Positioned(
              top: -10,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: AppBorderRadius.a8,
                ),
                child: Text(
                  'subscription.plan.annual_badge'.tr(),
                  style: AppTextStyles.s10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: AppBorderRadius.a24,
          border: Border.all(
            color: active ? AppColors.border : Colors.transparent,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.s14.copyWith(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
