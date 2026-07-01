import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';

/// The composer: a single "paper card" holding an attach button, a growing
/// text field, and the clay send button (the one accent moment in the footer).
class ChatInputBarWidget extends StatelessWidget {
  const ChatInputBarWidget({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSend,
    this.onAttach,
  });

  final TextEditingController controller;

  /// Whether the assistant can currently accept a message (cooldown / sending).
  final bool enabled;
  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(ChatStyle.cardRadius),
        border: Border.all(color: colors.borderDivider),
        boxShadow: AppShadows.e1Of(Theme.of(context).brightness),
      ),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _GhostIconButton(
            icon: Icons.add_photo_alternate_outlined,
            onTap: onAttach,
            color: colors.iconInactive,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                enabled: true,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                cursorColor: AppColors.primary,
                style: AppTextStyles.s14
                    .copyWith(color: colors.textPrimary, height: 1.4),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  hintText: 'chat.input_hint'.tr(),
                  hintStyle:
                      AppTextStyles.s14.copyWith(color: colors.inputHint),
                ),
              ),
            ),
          ),
          AppGap.w4,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = enabled && value.text.trim().isNotEmpty;
              return _SendButton(
                enabled: canSend,
                onTap: () => onSend(controller.text),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GhostIconButton extends StatelessWidget {
  const _GhostIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 21, color: color),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: 0.94,
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: ChatStyle.fast,
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: enabled
                ? AppShadows.e1Of(Theme.of(context).brightness)
                : const [],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.arrow_upward_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
