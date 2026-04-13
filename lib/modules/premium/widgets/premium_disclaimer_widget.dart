import 'package:cravvy_cooking_app/init.dart';

class PremiumDisclaimerWidget extends StatelessWidget {
  const PremiumDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppBorderRadius.a12,
      ),
      child: Text(
        'By subscribing, you agree to our Terms of Service and Privacy Policy. '
        'Your subscription will automatically renew unless canceled at least '
        '24 hours before the end of the current period.',
        textAlign: TextAlign.center,
        style: AppTextStyles.s12.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
