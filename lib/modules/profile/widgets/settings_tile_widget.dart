import 'package:cravvy_cooking_app/init.dart';

class SettingsTileWidget extends StatefulWidget {
  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.isToggle,
    required this.showDivider,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isToggle;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  State<SettingsTileWidget> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTileWidget> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        ListTile(
          contentPadding: AppPad.h16v4,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: AppBorderRadius.a10,
            ),
            child: Center(
              child: Icon(widget.icon, size: 18, color: colors.textPrimary),
            ),
          ),
          title: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: widget.label == 'Log Out'
                  ? AppColors.error
                  : colors.textPrimary,
            ),
          ),
          trailing: widget.isToggle
              ? Switch.adaptive(
                  value: _toggled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _toggled = v),
                )
              : SvgPicture.asset(
                  IconPath.rightArrow,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    colors.iconInactive,
                    BlendMode.srcIn,
                  ),
                ),
          // : const Icon(
          //     Icons.chevron_right_rounded,
          //     color: AppColors.textHint,
          //     size: 20,
          //   ),
          onTap: widget.isToggle ? null : widget.onTap,
        ),
        if (widget.showDivider)
          Divider(height: 0.1, color: colors.borderDivider),
      ],
    );
  }
}
