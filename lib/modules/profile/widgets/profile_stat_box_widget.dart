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
    final colors = context.appColors;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: context.themed(
              AppTextStyles.s10,
              color: colors.textSecondary,
            ),
          ),
          AppGap.h2,
          Text(
            value,
            style: context.themed(
              AppTextStyles.s16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
