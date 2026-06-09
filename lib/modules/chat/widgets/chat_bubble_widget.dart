import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/data/models/chat_message.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';

/// A single chat bubble. Assistant bubbles may render linked recipe cards.
class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isUser = message.isUser;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : colors.cardSurface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: isUser ? null : Border.all(color: colors.borderDivider),
      ),
      child: Text(
        message.content,
        style: AppTextStyles.s14.copyWith(
          color: isUser ? Colors.white : colors.textPrimary,
        ),
      ),
    );

    final recipes = _resolveRecipes(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          bubble,
          if (recipes.isNotEmpty) ...[
            AppGap.h8,
            ...recipes.map((r) => _RecipeChip(recipe: r)),
          ],
        ],
      ),
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

class _RecipeChip extends StatelessWidget {
  const _RecipeChip({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: colors.cardSurface,
        borderRadius: AppBorderRadius.a12,
        child: InkWell(
          borderRadius: AppBorderRadius.a12,
          onTap: () => context.push(AppRouter.mealDetail, extra: recipe.toMeal()),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.a12,
              border: Border.all(color: colors.borderDivider),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.a8,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: (recipe.imageUrl != null &&
                            recipe.imageUrl!.isNotEmpty)
                        ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ImageFallback(colors: colors),
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
                      Text(
                        '${recipe.calories} kcal · ${recipe.protein}g protein',
                        style: AppTextStyles.s11
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.iconInactive, size: 20),
              ],
            ),
          ),
        ),
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
      child: Icon(Icons.restaurant, size: 20, color: colors.iconInactive),
    );
  }
}

/// Animated "assistant is typing" indicator bubble.
class ChatTypingBubble extends StatelessWidget {
  const ChatTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.cardSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: colors.borderDivider),
          ),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
