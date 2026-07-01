import 'package:cravvy_cooking_app/init.dart';

/// The assistant identity mark: an ink (warm charcoal) circle with a clay
/// glyph, per the Vellum thread/header avatar. In dark mode the ink would
/// vanish, so it falls back to an elevated warm surface with a hairline.
class ChatAssistantAvatar extends StatelessWidget {
  const ChatAssistantAvatar({
    super.key,
    this.size = 30,
    this.icon = Icons.restaurant_menu_rounded,
  });

  final double size;
  final IconData icon;

  /// Warm charcoal "ink" ground (never pure black).
  static const Color _ink = Color(0xFF2A2622);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? colors.elevated : _ink,
        shape: BoxShape.circle,
        border: isDark ? Border.all(color: colors.borderDivider) : null,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.54, color: AppColors.primary),
    );
  }
}
