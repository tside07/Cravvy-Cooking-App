import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumHeaderWidget extends StatelessWidget {
  const PremiumHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Icon(
              Icons.arrow_back,
              color: colors.textPrimary,
              size: 24,
            ),
          ),
        ),
        AppGap.h20,

        // Crown icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('👑', style: TextStyle(fontSize: 36)),
          ),
        ),
        AppGap.h16,

        // Title
        Text(
          'premium.title'.tr(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.themed(AppTextStyles.h1),
        ),
        AppGap.h8,

        // Subtitle
        Text(
          'premium.subtitle'.tr(),
          textAlign: TextAlign.center,
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
