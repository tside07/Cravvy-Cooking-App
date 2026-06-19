import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/data/services/cooking_chat_service.dart';
import 'package:cravvy_cooking_app/modules/chat/provider/chat_provider.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_bubble_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_empty_state_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_input_bar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadHistory().then((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final provider = context.read<ChatProvider>();
    if (!provider.canSend) return;

    _inputController.clear();
    _scrollToBottom();
    await provider.send(trimmed, locale: context.locale.languageCode);
    _scrollToBottom();

    if (!mounted) return;
    final error = provider.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_errorText(error))));
      provider.clearError();
    }
  }

  String _errorText(CookingChatException e) {
    switch (e.kind) {
      case ChatErrorKind.dailyLimit:
        return 'chat.error_daily_limit'.tr();
      case ChatErrorKind.busy:
        return 'chat.error_busy'.tr();
      case ChatErrorKind.network:
      case ChatErrorKind.failed:
        return 'chat.error_generic'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.backgroundMain,
      appBar: AppBar(
        title: Text('chat.title'.tr(), style: context.themed(AppTextStyles.s17)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _DisclaimerBanner(colors: colors),
          Expanded(child: _buildBody(provider)),
          ChatInputBarWidget(
            controller: _inputController,
            enabled: provider.canSend,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChatProvider provider) {
    if (provider.isLoadingHistory && provider.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.isEmpty && !provider.isSending) {
      return ChatEmptyStateWidget(onSuggestionTap: _handleSend);
    }

    final messages = provider.messages;
    final itemCount = messages.length + (provider.isSending ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const ChatTypingBubble();
        }
        return ChatBubbleWidget(message: messages[index]);
      },
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.colors});
  final AppColorExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.elevated,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: colors.textSecondary),
          AppGap.w8,
          Expanded(
            child: Text(
              'chat.disclaimer'.tr(),
              style: AppTextStyles.s11.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
