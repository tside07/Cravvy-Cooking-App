import 'package:cravvy_cooking_app/init.dart';

class ProfileStatBoxWidget extends StatelessWidget {
  const ProfileStatBoxWidget({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.s10.copyWith(color: AppColors.textSecondary),
          ),
          AppGap.h2,
          Text(
            value,
            style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
