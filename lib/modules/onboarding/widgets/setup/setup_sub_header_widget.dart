import 'package:cravvy_cooking_app/init.dart';

class SetupSubHeaderWidget extends StatelessWidget {
  final String text;

  const SetupSubHeaderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.themed(
          AppTextStyles.s14,
          fontWeight: FontWeight.w700,
        ),
      );
}
