import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumBannerWidget extends StatelessWidget {
  const PremiumBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push(AppRouter.subscription),
      child: Container(
        margin: AppPad.section16t14,
        padding: AppPad.a16,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: AppBorderRadius.card,
          boxShadow: AppShadows.e2Of(Theme.of(context).brightness),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              IconPath.crown,
              width: 35,
              height: 35,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.upgrade'.tr(),
                    style: AppTextStyles.s14.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'profile.upgrade_subtitle'.tr(),
                    style: AppTextStyles.s12.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              IconPath.rightArrow,
              width: 25,
              height: 25,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
