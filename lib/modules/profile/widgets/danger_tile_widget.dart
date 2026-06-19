import 'package:cravvy_cooking_app/init.dart';

class DangerTileWidget extends StatelessWidget {
  const DangerTileWidget({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.a8,
        child: Padding(
          padding: AppPad.h4v8,
          child: Text(
            label,
            style: AppTextStyles.s14.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
