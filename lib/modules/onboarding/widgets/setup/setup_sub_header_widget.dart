import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class SetupSubHeaderWidget extends StatelessWidget {
  final String text;

  const SetupSubHeaderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.s14.copyWith(
          fontWeight: FontWeight.w700,
          color: PreAuthTheme.textPrimary,
        ),
      );
}
