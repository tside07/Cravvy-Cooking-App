import 'dart:math' as math;

import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/models/chat_session.dart';
import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';
import 'package:cravvy_cooking_app/modules/chat/provider/chat_provider.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_icon_button.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';

/// Right-side slide-over menu opened from the header 3-dots: account, navigation
/// tabs, the Cravvy assistants, and recent chats with rename/delete actions.
class ChatMenuDrawer extends StatefulWidget {
  const ChatMenuDrawer({super.key});

  @override
  State<ChatMenuDrawer> createState() => _ChatMenuDrawerState();
}

class _ChatMenuDrawerState extends State<ChatMenuDrawer> {
  bool _recentCollapsed = false;

  void _close() => Scaffold.of(context).closeEndDrawer();

  void _goTo(String route) {
    _close();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final provider = context.watch<ChatProvider>();
    final width = math.min(300.0, MediaQuery.sizeOf(context).width * 0.86);
    final recents = provider.recentSessions;

    return Drawer(
      width: width,
      backgroundColor: colors.backgroundMain,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AccountRow(),
            _DrawerTabs(
              onSettings: () => _goTo(AppRouter.settings),
              onPayment: () => _goTo(AppRouter.subscription),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _SectionLabel(
                    label: 'chat.drawer.assistants_label'.tr(),
                    trailing: ChatIconButton(
                      icon: Icons.more_vert_rounded,
                      iconSize: 18,
                      size: 30,
                      onTap: () => _showAssistantMenu(provider),
                    ),
                  ),
                  ...ChatAssistant.values.map(
                    (a) => _AssistantRow(
                      assistant: a,
                      active: provider.currentAssistant == a,
                      onTap: () {
                        provider.selectAssistant(a);
                        _close();
                      },
                    ),
                  ),
                  AppGap.h8,
                  _SectionLabel(
                    label: 'chat.drawer.recent_label'.tr(),
                    trailing: ChatIconButton(
                      icon: _recentCollapsed
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      iconSize: 20,
                      size: 30,
                      onTap: () => setState(
                        () => _recentCollapsed = !_recentCollapsed,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: ChatStyle.fast,
                    alignment: Alignment.topCenter,
                    curve: Curves.easeOut,
                    child: _recentCollapsed
                        ? const SizedBox(width: double.infinity)
                        : Column(
                            children: recents.isEmpty
                                ? [_EmptyRecent(colors: colors)]
                                : recents
                                    .map(
                                      (s) => _RecentChatRow(
                                        session: s,
                                        active:
                                            provider.currentSession?.id == s.id,
                                        onTap: () {
                                          provider.switchSession(s.id);
                                          _close();
                                        },
                                        onRename: () => _renameSession(s),
                                        onDelete: () => _deleteSession(s),
                                      ),
                                    )
                                    .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void _showAssistantMenu(ChatProvider provider) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.elevated,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add_comment_outlined, color: colors.textPrimary),
              title: Text('chat.drawer.new_chat'.tr(),
                  style: context.themed(AppTextStyles.s15)),
              onTap: () {
                Navigator.pop(sheetContext);
                provider.newChat();
                _close();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameSession(ChatSession session) async {
    final provider = context.read<ChatProvider>();
    final colors = context.appColors;
    final controller = TextEditingController(
      text: session.title ?? session.derivedTitle ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.elevated,
        title: Text('chat.drawer.rename_title'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'chat.drawer.rename_hint'.tr()),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('chat.drawer.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('chat.drawer.save'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.trim().isNotEmpty) {
      await provider.renameSession(session.id, result);
    }
  }

  Future<void> _deleteSession(ChatSession session) async {
    final provider = context.read<ChatProvider>();
    final colors = context.appColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.elevated,
        title: Text('chat.drawer.delete_title'.tr()),
        content: Text('chat.drawer.delete_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('chat.drawer.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('chat.drawer.delete'.tr()),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.deleteSession(session.id);
    }
  }
}

// ─── Account row ───────────────────────────────────────────────────────────────

class _AccountRow extends StatelessWidget {
  const _AccountRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final name = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'chat.drawer.guest'.tr();

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderDivider)),
      ),
      child: InkWell(
        onTap: () {
          Scaffold.of(context).closeEndDrawer();
          context.push(AppRouter.editProfile);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? colors.chipSelectedBg : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  profile.initials,
                  style: ChatStyle.monoMeta(
                    isDark ? AppColors.primary : AppColors.primaryDark,
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ChatStyle.monoMeta(
                        colors.textPrimary,
                        size: 14,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (profile.email.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.email.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ChatStyle.monoMeta(colors.textDisabled, size: 11),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: colors.iconInactive),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tabs ──────────────────────────────────────────────────────────────────────

class _DrawerTabs extends StatelessWidget {
  const _DrawerTabs({required this.onSettings, required this.onPayment});

  final VoidCallback onSettings;
  final VoidCallback onPayment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderDivider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab(label: 'chat.drawer.tab_main'.tr(), active: true, onTap: () {}),
          AppGap.w20,
          _Tab(
            label: 'chat.drawer.tab_settings'.tr(),
            active: false,
            onTap: onSettings,
          ),
          AppGap.w20,
          _Tab(
            label: 'chat.drawer.tab_payment'.tr(),
            active: false,
            onTap: onPayment,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.s14.copyWith(
                color: active ? colors.textPrimary : colors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 22,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: ChatStyle.monoCaps(colors.textDisabled, size: 10),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ─── Assistant row ───────────────────────────────────────────────────────────────

class _AssistantRow extends StatelessWidget {
  const _AssistantRow({
    required this.assistant,
    required this.active,
    required this.onTap,
  });

  final ChatAssistant assistant;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? colors.chipSelectedBg : AppColors.primaryLight;
    final activeText = isDark ? AppColors.primary : AppColors.primaryDark;
    final wellHover = isDark ? colors.elevated : colors.backgroundMain;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: active ? tint : Colors.transparent,
        borderRadius: BorderRadius.circular(ChatStyle.controlRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: wellHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  assistant.icon,
                  size: 19,
                  color: active ? AppColors.primary : colors.iconInactive,
                ),
                AppGap.w12,
                Expanded(
                  child: Text(
                    assistant.nameKey.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s14.copyWith(
                      color: active ? activeText : colors.textPrimary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recent chat row ───────────────────────────────────────────────────────────────

class _RecentChatRow extends StatelessWidget {
  const _RecentChatRow({
    required this.session,
    required this.active,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final ChatSession session;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? colors.chipSelectedBg : AppColors.primaryLight;
    final activeText = isDark ? AppColors.primary : AppColors.primaryDark;
    final wellHover = isDark ? colors.elevated : colors.backgroundMain;
    final title = session.title ?? session.derivedTitle ?? 'chat.new_chat'.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: active ? tint : Colors.transparent,
        borderRadius: BorderRadius.circular(ChatStyle.controlRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: wellHover,
          child: Container(
            // 2px inset accent left rule on the active chat.
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: active ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s13.copyWith(
                      color: active ? activeText : colors.textPrimary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (active) ...[
                  ChatIconButton(
                    icon: Icons.edit_outlined,
                    iconSize: 16,
                    size: 28,
                    onTap: onRename,
                  ),
                  _DeleteButton(onDelete: onDelete),
                ] else ...[
                  Text(
                    ChatStyle.relativeShort(session.updatedAt),
                    style: ChatStyle.monoMeta(colors.textDisabled, size: 10.5),
                  ),
                  _MoreButton(onRename: onRename, onDelete: onDelete),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Delete button that turns danger on hover/press.
class _DeleteButton extends StatefulWidget {
  const _DeleteButton({required this.onDelete});
  final VoidCallback onDelete;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ChatIconButton(
        icon: Icons.delete_outline_rounded,
        iconSize: 16,
        size: 28,
        color: _hover ? AppColors.error : colors.iconInactive,
        onTap: widget.onDelete,
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onRename, required this.onDelete});
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopupMenuButton<int>(
      tooltip: '',
      icon: Icon(Icons.more_horiz_rounded, size: 18, color: colors.iconInactive),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      color: colors.elevated,
      onSelected: (v) => v == 0 ? onRename() : onDelete(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: colors.textSecondary),
              AppGap.w12,
              Text('chat.drawer.rename'.tr(), style: AppTextStyles.s14),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              AppGap.w12,
              Text(
                'chat.drawer.delete'.tr(),
                style: AppTextStyles.s14.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.colors});
  final AppColorExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 16, 6),
      child: Text(
        'chat.drawer.empty_recent'.tr(),
        style: AppTextStyles.s13.copyWith(color: colors.textDisabled),
      ),
    );
  }
}
