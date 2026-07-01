import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_assistant_avatar.dart';

/// Welcome panel shown when the current conversation has no messages yet.
class ChatEmptyStateWidget extends StatelessWidget {
  const ChatEmptyStateWidget({super.key, required this.assistant});

  final ChatAssistant assistant;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ChatAssistantAvatar(size: 60, icon: assistant.icon),
          AppGap.h20,
          Text(
            assistant.nameKey.tr(),
            textAlign: TextAlign.center,
            style: ChatStyle.display(colors.textPrimary, size: 22),
          ),
          AppGap.h8,
          Text(
            'chat.empty_state'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.s14
                .copyWith(color: colors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
