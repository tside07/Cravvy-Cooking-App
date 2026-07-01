import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';

/// Horizontal scroll row of quick-prompt pills above the composer. Labels come
/// from the active assistant; tapping sends the label as a message.
class ChatSuggestionsRow extends StatelessWidget {
  const ChatSuggestionsRow({
    super.key,
    required this.suggestionKeys,
    required this.onTap,
  });

  final List<String> suggestionKeys;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: suggestionKeys.length,
        separatorBuilder: (_, _) => AppGap.w8,
        itemBuilder: (context, i) {
          final label = suggestionKeys[i].tr();
          return Pressable(
            pressedScale: 0.96,
            onTap: () => onTap(label),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.cardSurface,
                borderRadius: BorderRadius.circular(ChatStyle.controlRadius),
                border: Border.all(color: colors.borderDivider),
                boxShadow: AppShadows.e1Of(Theme.of(context).brightness),
              ),
              child: Text(
                label,
                style: AppTextStyles.s12.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
