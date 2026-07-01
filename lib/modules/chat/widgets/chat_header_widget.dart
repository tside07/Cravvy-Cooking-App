import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_assistant_avatar.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_icon_button.dart';

/// Fixed chat header: back chevron · assistant identity · status · 3-dots menu.
class ChatHeaderWidget extends StatelessWidget {
  const ChatHeaderWidget({
    super.key,
    required this.assistant,
    required this.isSending,
    required this.onBack,
    required this.onMenu,
  });

  final ChatAssistant assistant;
  final bool isSending;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = isSending ? AppColors.primary : AppColors.success;
    final statusLabel =
        (isSending ? 'chat.header_status_typing' : 'chat.header_status_online')
            .tr()
            .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(bottom: BorderSide(color: colors.borderDivider)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                ChatIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 18,
                  color: colors.textSecondary,
                  onTap: onBack,
                ),
                AppGap.w4,
                ChatAssistantAvatar(size: 34, icon: assistant.icon),
                AppGap.w10,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assistant.nameKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ChatStyle.display(colors.textPrimary, size: 17),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppGap.w6,
                          Text(
                            statusLabel,
                            style: ChatStyle.monoCaps(
                              colors.textSecondary,
                              size: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ChatIconButton(
                  icon: Icons.more_horiz_rounded,
                  color: colors.textSecondary,
                  onTap: onMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
