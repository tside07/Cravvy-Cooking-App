import 'package:cravvy_cooking_app/init.dart';

/// Ghost icon button used across the chat screen and drawer. Presses scale to
/// 0.94 (spec §6); on pointer devices it warms one surface step on hover.
class ChatIconButton extends StatefulWidget {
  const ChatIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final String? tooltip;

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onTap != null;
    final hoverBg = isDark ? colors.elevated : colors.backgroundMain;

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: Pressable(
        pressedScale: 0.94,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _hover && enabled ? hoverBg : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.color ?? colors.iconInactive,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
