import 'package:cravvy_cooking_app/init.dart';

class PremiumBannerWidget extends StatelessWidget {
  const PremiumBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        top: 14,
        right: 16,
      ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: AppBorderRadius.a18,
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Unlock AI meal planning & more',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
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
            child: const Text(
              'Try Free',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
