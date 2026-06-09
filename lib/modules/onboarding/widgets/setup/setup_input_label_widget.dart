import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

class SetupInputLabelWidget extends StatelessWidget {
  final String text;

  const SetupInputLabelWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.s14.copyWith(
          fontWeight: FontWeight.w600,
          color: PreAuthTheme.textPrimary,
        ),
      );
}
