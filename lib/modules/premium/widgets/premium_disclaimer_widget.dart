import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

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
        'premium.sub_desc'.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.s12.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
