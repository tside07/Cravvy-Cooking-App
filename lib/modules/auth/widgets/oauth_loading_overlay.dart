import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shown while waiting for an external OAuth browser session.
class OAuthLoadingOverlay extends StatelessWidget {
  const OAuthLoadingOverlay({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PreAuthTheme.background.withValues(alpha: 0.97),
      child: Center(
        child: Padding(
          padding: AppPad.h32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              AppGap.h20,
              Text(
                'welcome.oauth_waiting'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.s15.copyWith(
                  color: PreAuthTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              AppGap.h24,
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  label: Text(
                    'welcome.oauth_cancel'.tr(),
                    style: AppTextStyles.s15.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.a14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
