import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPasswordSuccessWidget extends StatelessWidget {
  const ResetPasswordSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            AppGap.h24,
            Text(
              'auth.reset_success_title'.tr(),
              style: context.themed(AppTextStyles.h1),
            ),
            AppGap.h12,
            Text(
              'auth.reset_success_body'.tr(),
              textAlign: TextAlign.center,
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
