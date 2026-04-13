import 'package:cravvy_cooking_app/init.dart';

class PremiumHeaderWidget extends StatelessWidget {
  const PremiumHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
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
          'Upgrade to Cravvy Premium',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.s20.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        AppGap.h8,

        // Subtitle
        Text(
          'Unlock the full power of meal planning',
          textAlign: TextAlign.center,
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
