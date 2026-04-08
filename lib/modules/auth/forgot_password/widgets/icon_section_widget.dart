import 'package:cravvy_cooking_app/init.dart';

class IconSectionWidget extends StatelessWidget {
  const IconSectionWidget({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, size: 36, color: AppColors.primary)),
    );
  }
}
