import 'package:cravvy_cooking_app/init.dart';

/// Themed surface wrapper. Prefer [AppInputDecoration.underline] on fields
/// without this wrapper to avoid double borders/backgrounds.
class FieldCardWidget extends StatelessWidget {
  const FieldCardWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: context.cardBox(radius: 14),
        child: child,
      );
}
