import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class TrialExpiryNoteWidget extends StatelessWidget {
  const TrialExpiryNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.h16v10,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.a12,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: AppColors.warning,
          ),
          AppGap.w8,
          Expanded(
            child: Text(
              'trial.expiry_note'.tr(),
              style: AppTextStyles.s12.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
