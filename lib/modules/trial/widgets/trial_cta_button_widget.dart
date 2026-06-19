import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class TrialCtaButtonWidget extends StatelessWidget {
  const TrialCtaButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.explore_outlined, size: 20),
        label: Text('trial.explore_btn'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.button),
          textStyle: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
