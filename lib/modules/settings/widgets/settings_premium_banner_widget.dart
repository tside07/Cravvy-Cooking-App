import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPremiumBannerWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsPremiumBannerWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: AppPad.a20,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppBorderRadius.a16,
          boxShadow: AppShadows.e2Of(Theme.of(context).brightness),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppBorderRadius.card,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings.upgrade_title'.tr(),
                    style: AppTextStyles.s16.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'settings.upgrade_subtitle'.tr(),
                    style: AppTextStyles.s12.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
