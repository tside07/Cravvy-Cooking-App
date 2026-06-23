import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

/// Welcome state shown when there is no chat history yet:
/// an intro + tappable suggestion chips to seed the conversation.
class ChatEmptyStateWidget extends StatelessWidget {
  const ChatEmptyStateWidget({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  static const _suggestionKeys = [
    'chat.suggestion_1',
    'chat.suggestion_2',
    'chat.suggestion_3',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
          AppGap.h16,
          Text(
            'chat.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: context.themed(AppTextStyles.s18),
          ),
          AppGap.h8,
          Text(
            'chat.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.s14.copyWith(color: colors.textSecondary),
          ),
          AppGap.h24,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _suggestionKeys.map((key) {
              final label = key.tr();
              return ActionChip(
                label: Text(label, style: context.themed(AppTextStyles.s13)),
                backgroundColor: colors.chipBg,
                side: BorderSide(color: colors.chipBorder),
                onPressed: () => onSuggestionTap(label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
