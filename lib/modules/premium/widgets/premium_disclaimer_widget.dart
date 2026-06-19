import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumDisclaimerWidget extends StatelessWidget {
  const PremiumDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: AppBorderRadius.a12,
      ),
      child: Text(
        'premium.sub_desc'.tr(),
        textAlign: TextAlign.center,
        style: context.themed(
          AppTextStyles.s12,
          color: colors.textSecondary,
        ).copyWith(height: 1.5),
      ),
    );
  }
}
