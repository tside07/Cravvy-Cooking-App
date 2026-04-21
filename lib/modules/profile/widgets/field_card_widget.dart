import 'package:cravvy_cooking_app/init.dart';

class FieldCardWidget extends StatelessWidget {
  const FieldCardWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.a14,
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}
