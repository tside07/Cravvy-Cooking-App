import 'package:cravvy_cooking_app/init.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: context.themed(
            AppTextStyles.s20,
            fontWeight: FontWeight.w800,
          ).copyWith(fontSize: 28),
        ),
        AppGap.h6,
        Text(
          'Sign in to continue your healthy food journey',
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
