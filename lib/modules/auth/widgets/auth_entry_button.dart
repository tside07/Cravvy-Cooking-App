import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';

/// Lifesum-style white provider button on black pre-auth screens.
class AuthEntryButton extends StatelessWidget {
  const AuthEntryButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.leading,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget leading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: PreAuthTheme.buttonFill,
          foregroundColor: PreAuthTheme.buttonText,
          disabledBackgroundColor: PreAuthTheme.buttonFill.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            AppGap.w12,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PreAuthTheme.buttonText,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
