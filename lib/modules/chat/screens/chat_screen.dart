import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/services/cooking_chat_service.dart';
import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';
import 'package:cravvy_cooking_app/modules/chat/provider/chat_provider.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_bubble_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_empty_state_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_header_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_input_bar_widget.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_menu_drawer.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_suggestions_row.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init().then((_) => _scrollToBottom());
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
        duration: ChatStyle.base,
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
    final future = provider.send(trimmed, locale: context.locale.languageCode);
    _scrollToBottom();
    await future;
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

  void _handleAttach() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('chat.attach_coming_soon'.tr())));
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
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
    final assistant = provider.currentAssistant;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.backgroundMain,
      endDrawer: const ChatMenuDrawer(),
      drawerScrimColor: const Color(0x661B1714),
      body: Column(
        children: [
          ChatHeaderWidget(
            assistant: assistant,
            isSending: provider.isSending,
            onBack: _handleBack,
            onMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(child: _buildThread(provider, assistant)),
          _buildFooter(provider, assistant, colors),
        ],
      ),
    );
  }

  Widget _buildThread(ChatProvider provider, ChatAssistant assistant) {
    if (provider.isInitializing && provider.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.isEmpty && !provider.isSending) {
      return ChatEmptyStateWidget(assistant: assistant);
    }

    final messages = provider.messages;
    final children = <Widget>[];
    DateTime? lastDay;
    for (final m in messages) {
      final created = m.createdAt;
      if (created != null &&
          (lastDay == null || !ChatStyle.isSameDay(created, lastDay))) {
        children.add(_DaySeparator(label: _dayLabel(created)));
        lastDay = created;
      }
      children.add(ChatBubbleWidget(message: m, assistant: assistant));
    }
    if (provider.isSending) {
      children.add(ChatTypingBubble(assistant: assistant));
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      children: children,
    );
  }

  Widget _buildFooter(
    ChatProvider provider,
    ChatAssistant assistant,
    AppColorExtension colors,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatSuggestionsRow(
              suggestionKeys: assistant.suggestionKeys,
              onTap: _handleSend,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChatInputBarWidget(
                controller: _inputController,
                enabled: provider.canSend,
                onSend: _handleSend,
                onAttach: _handleAttach,
              ),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'chat.disclaimer'.tr(),
                textAlign: TextAlign.center,
                style: ChatStyle.monoMeta(colors.textDisabled, size: 10.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (ChatStyle.isSameDay(d, now)) return 'chat.today'.tr();
    if (ChatStyle.isSameDay(d, now.subtract(const Duration(days: 1)))) {
      return 'chat.yesterday'.tr();
    }
    return DateFormat('MMM d', context.locale.toString()).format(d);
  }
}

/// Centered mono-caps day marker between message groups.
class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: ChatStyle.monoCaps(context.appColors.textDisabled, size: 10),
        ),
      ),
    );
  }
}
