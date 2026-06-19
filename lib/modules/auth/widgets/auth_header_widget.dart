
import 'package:cravvy_cooking_app/init.dart';

class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.start,
  });

  final String title;
  final String subtitle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: context.themed(
            AppTextStyles.h1.copyWith(fontSize: 28),
          ),
        ),
        AppGap.h6,
        Text(
          subtitle,
          textAlign: textAlign,
          style: AppTextStyles.s14.copyWith(
            color: appColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
