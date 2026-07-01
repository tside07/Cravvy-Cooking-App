import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/data/models/chat_assistant.dart';
import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/chat/chat_style.dart';
import 'package:cravvy_cooking_app/modules/chat/widgets/chat_assistant_avatar.dart';

/// A single chat row. User turns sit right (clay ground); assistant turns sit
/// left behind an ink avatar (paper ground) and may render linked recipe cards.
class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.assistant = ChatAssistant.aiChef,
  });

  final ChatMessage message;
  final ChatAssistant assistant;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: isUser ? _buildUser(context) : _buildAssistant(context),
    );
  }

  // ─── User: clay, right-aligned, tail bottom-right ────────────────────────────
  Widget _buildUser(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.80;
    final time = message.createdAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ChatStyle.bubbleRadius),
              topRight: Radius.circular(ChatStyle.bubbleRadius),
              bottomLeft: Radius.circular(ChatStyle.bubbleRadius),
              bottomRight: Radius.circular(ChatStyle.tailRadius),
            ),
          ),
          child: Text(
            message.content,
            style: AppTextStyles.s14.copyWith(color: Colors.white, height: 1.45),
          ),
        ),
        if (time != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              ChatStyle.timeOfDay(time),
              style: ChatStyle.monoMeta(context.appColors.textDisabled),
            ),
          ),
      ],
    );
  }

  // ─── Assistant: paper, left-aligned, ink avatar, tail bottom-left ────────────
  Widget _buildAssistant(BuildContext context) {
    final colors = context.appColors;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.80;
    final recipes = _resolveRecipes(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatAssistantAvatar(size: 30, icon: assistant.icon),
        AppGap.w8,
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.cardSurface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(ChatStyle.bubbleRadius),
                    topRight: Radius.circular(ChatStyle.bubbleRadius),
                    bottomLeft: Radius.circular(ChatStyle.tailRadius),
                    bottomRight: Radius.circular(ChatStyle.bubbleRadius),
                  ),
                  border: Border.all(color: colors.borderDivider),
                  boxShadow: AppShadows.e1Of(Theme.of(context).brightness),
                ),
                child: Text(
                  message.content,
                  style: AppTextStyles.s14
                      .copyWith(color: colors.textPrimary, height: 1.5),
                ),
              ),
              if (recipes.isNotEmpty) ...[
                AppGap.h8,
                ...recipes.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ChatRecipeCard(recipe: r),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Recipe> _resolveRecipes(BuildContext context) {
    if (message.referencedRecipeIds.isEmpty) return const [];
    final all = context.read<RecipeProvider>().allRecipes;
    if (all.isEmpty) return const [];
    final byId = {for (final r in all) r.id: r};
    return [
      for (final id in message.referencedRecipeIds)
        if (byId[id] != null) byId[id]!,
    ];
  }
}

/// Recipe result tile under an assistant bubble: thumbnail · name · mono stats.
class ChatRecipeCard extends StatelessWidget {
  const ChatRecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stats = '${recipe.calories} kcal · ${recipe.protein}g protein'
        '${recipe.prepTime > 0 ? ' · ${recipe.prepTime} min' : ''}';

    return PressableCard(
      radius: ChatStyle.cardRadius,
      padding: const EdgeInsets.all(8),
      border: Border.all(color: colors.borderDivider),
      restShadow: AppShadows.e1Of(Theme.of(context).brightness),
      onTap: () => context.push(AppRouter.mealDetail, extra: recipe.toMeal()),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.a10,
            child: SizedBox(
              width: 46,
              height: 46,
              child: (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ImageFallback(colors: colors),
                    )
                  : _ImageFallback(colors: colors),
            ),
          ),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.themed(
                    AppTextStyles.s13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stats,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ChatStyle.monoMeta(colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.iconInactive, size: 20),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.colors});
  final AppColorExtension colors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.elevated,
      child: Icon(Icons.restaurant_rounded, size: 20, color: colors.iconInactive),
    );
  }
}

/// Animated "assistant is typing" indicator: ink avatar + three settling dots.
class ChatTypingBubble extends StatefulWidget {
  const ChatTypingBubble({super.key, this.assistant = ChatAssistant.aiChef});

  final ChatAssistant assistant;

  @override
  State<ChatTypingBubble> createState() => _ChatTypingBubbleState();
}

class _ChatTypingBubbleState extends State<ChatTypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduceMotion) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatAssistantAvatar(size: 30, icon: widget.assistant.icon),
          AppGap.w8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ChatStyle.bubbleRadius),
                topRight: Radius.circular(ChatStyle.bubbleRadius),
                bottomLeft: Radius.circular(ChatStyle.tailRadius),
                bottomRight: Radius.circular(ChatStyle.bubbleRadius),
              ),
              border: Border.all(color: colors.borderDivider),
              boxShadow: AppShadows.e1Of(Theme.of(context).brightness),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => _dot(i, colors)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i, AppColorExtension colors) {
    // Each dot peaks a third of a cycle apart; gentle settle, no bounce.
    final phase = (_controller.value - i * 0.18) % 1.0;
    final t = (phase < 0.5) ? phase * 2 : (1 - phase) * 2;
    final opacity = 0.35 + 0.65 * t.clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: colors.textSecondary.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
