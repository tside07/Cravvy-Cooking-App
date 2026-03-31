import 'package:cravvy_cooking_app/init.dart';

class SettingsTileWidget extends StatefulWidget {
  const SettingsTileWidget({
    super.key,
    required this.emoji,
    required this.label,
    required this.isToggle,
    required this.showDivider,
    required this.onTap,
  });

  final String emoji;
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
    return Column(
      children: [
        ListTile(
          contentPadding: AppPad.h16v4,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppBorderRadius.a10,
            ),
            child: Center(
              child: Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          title: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: widget.label == 'Log Out'
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
          trailing: widget.isToggle
              ? Switch.adaptive(
                  value: _toggled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _toggled = v),
                )
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
          onTap: widget.isToggle ? null : widget.onTap,
        ),
        if (widget.showDivider)
          const Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: AppColors.divider,
          ),
      ],
    );
  }
}
