import 'package:cravvy_cooking_app/init.dart';

class EditProfileSectionHeaderWidget extends StatelessWidget {
  const EditProfileSectionHeaderWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: context.themed(
            const TextStyle(fontSize: 11, letterSpacing: 0.8),
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
