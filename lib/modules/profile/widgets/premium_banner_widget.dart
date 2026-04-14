import 'package:cravvy_cooking_app/init.dart';

class PremiumBannerWidget extends StatelessWidget {
  const PremiumBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.premium),
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 14, right: 16),
        padding: AppPad.a16,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: AppBorderRadius.a18,
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
                    'Upgrade to Premium',
                    style: AppTextStyles.s14.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Unlock AI meal planning & more',
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
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn,),
            ),
          ],
        ),
      ),
    );
  }
}
