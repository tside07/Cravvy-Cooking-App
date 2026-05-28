import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_highlight.dart';

class HighlightTileWidget extends StatelessWidget {
  const HighlightTileWidget({super.key, required this.highlight});

  final SubscriptionHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a14,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a14,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: highlight.color.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.a12,
            ),
            child: Icon(highlight.icon, color: highlight.color, size: 22),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppGap.h2,
                Text(
                  highlight.desc,
                  style: AppTextStyles.s12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
