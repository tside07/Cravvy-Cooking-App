import 'package:cravvy_cooking_app/init.dart';

class PremiumBannerWidget extends StatelessWidget {
  const PremiumBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.premium),
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          top: 14,
          right: 16,
        ),
        padding: AppPad.a16,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: AppBorderRadius.a18,
        ),
        child: Row(
          children: [
            Text('⭐', style: AppTextStyles.s20.copyWith(fontSize: 28)),
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
            Container(
              padding: AppPad.h14v8,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppBorderRadius.a12,
              ),
              child: Text(
                'Try Free',
                style: AppTextStyles.s12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
