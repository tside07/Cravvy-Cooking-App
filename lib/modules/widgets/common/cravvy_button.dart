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
    if (isOutlined) {
      return OutlinedButton(onPressed: isLoading ? null : onTap, child: _child);
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _child,
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
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      );
    }
    return Text(label);
  }
}
