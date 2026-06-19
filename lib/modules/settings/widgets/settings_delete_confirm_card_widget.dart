import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsDeleteConfirmCardWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const SettingsDeleteConfirmCardWidget({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppBorderRadius.card,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.delete_confirm_title'.tr(),
            style: AppTextStyles.s14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          AppGap.h6,
          Text(
            'settings.delete_confirm_body'.tr(),
            style: AppTextStyles.s12.copyWith(color: AppColors.error),
          ),
          AppGap.h12,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.button,
                    ),
                  ),
                  child: Text(
                    'common.cancel'.tr(),
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
              AppGap.w10,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.button,
                    ),
                  ),
                  child: Text(
                    'common.delete'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
