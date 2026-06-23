import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

/// Small reassurance banner shown when a paid plan is selected: the 14-day
/// trial auto-cancels and the user is never silently charged.
class TrialAutoCancelNoticeWidget extends StatelessWidget {
  const TrialAutoCancelNoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: AppBorderRadius.a12,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          AppGap.w10,
          Expanded(
            child: Text(
              'subscription.auto_cancel_note'.tr(
                namedArgs: {'days': '${PlanLimits.premiumTrialDays}'},
              ),
              style: context
                  .themed(AppTextStyles.s12, color: colors.textSecondary)
                  .copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
