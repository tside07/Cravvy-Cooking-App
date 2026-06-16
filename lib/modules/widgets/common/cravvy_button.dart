import 'package:cravvy_cooking_app/init.dart';

class CravvyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const CravvyButton({
    super.key,
    required this.label,
    this.onTap,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled while loading or when no handler is provided.
    final isDisabled = isLoading || onTap == null;
    final shape = RoundedRectangleBorder(borderRadius: AppBorderRadius.button);

    final Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isDisabled ? null : onTap,
            style: OutlinedButton.styleFrom(shape: shape),
            child: _child,
          )
        : ElevatedButton(
            onPressed: isDisabled ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              disabledBackgroundColor:
                  (backgroundColor ?? AppColors.primary).withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              minimumSize: const Size(double.infinity, 56),
              shape: shape,
            ),
            child: _child,
          );

    // Press feedback (scale) only when the button is actually actionable.
    return Pressable(
      onTap: isDisabled ? null : onTap,
      child: AbsorbPointer(child: button),
    );
  }

  Widget get _child {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), AppGap.w8, Text(label)],
      );
    }
    return Text(label);
  }
}
