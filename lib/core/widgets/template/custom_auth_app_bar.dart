import 'package:cravvy_cooking_app/common/widgets/images/custom_asset_svg_picture.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/resources/resources.dart';

class CustomAuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAuthAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: AppPad.l24,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: AppPad.a5,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomAssetSvgPicture(
                IconPath.arrowLeft,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
