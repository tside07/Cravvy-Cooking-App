import 'package:cravvy_cooking_app/init.dart';

class EditProfileSectionHeaderWidget extends StatelessWidget {
  const EditProfileSectionHeaderWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      );
}
