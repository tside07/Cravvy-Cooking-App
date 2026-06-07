import 'package:cravvy_cooking_app/init.dart';

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
              'Password Updated!',
              style: context.themed(
                AppTextStyles.s20,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: 24),
            ),
            AppGap.h12,
            Text(
              'Your password has been reset successfully.\nRedirecting to login…',
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
