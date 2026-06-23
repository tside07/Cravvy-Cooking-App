import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

/// Cravvy wordmark for the dark auth shell. Gives login/register a brand
/// anchor instead of opening cold on a bare title. Falls back to styled text
/// if the wordmark asset is missing.
class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.height = 26});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        PreAuthTheme.textPrimary,
        BlendMode.srcIn,
      ),
      child: Image.asset(
        ImagePath.appName,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          AppConst.appName,
          style: AppTextStyles.h1.copyWith(
            color: PreAuthTheme.textPrimary,
            fontSize: height,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
