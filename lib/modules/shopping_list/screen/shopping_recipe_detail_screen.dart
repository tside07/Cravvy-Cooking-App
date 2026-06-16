import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// Cart-style detail of one recipe's ingredients with quantity steppers.
class ShoppingRecipeDetailScreen extends StatelessWidget {
  const ShoppingRecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final colors = context.appColors;
    final provider = context.watch<ShoppingListProvider>();
    final items = provider.itemsForRecipe(recipeId);
    final recipeName = provider.recipeNameOf(recipeId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'shopping_list.cart_title'.tr(),
          style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'shopping_list.empty_desc'.tr(),
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
                ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: AppPad.a16,
                      children: [
                        if (recipeName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, left: 4),
                            child: Text(
                              recipeName,
                              style: AppTextStyles.s16
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ...items.map(
                          (item) => _IngredientCartTile(
                            item: item,
                            onIncrement: () => context
                                .read<ShoppingListProvider>()
                                .increment(item.id),
                            onDecrement: () => context
                                .read<ShoppingListProvider>()
                                .decrement(item.id),
                            onToggle: () => context
                                .read<ShoppingListProvider>()
                                .toggle(item.id),
                            onRemove: () => context
                                .read<ShoppingListProvider>()
                                .remove(item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _OrderSummaryBar(
                    totalCount: items.length,
                    boughtCount: items.where((i) => i.checked).length,
                    onMarkBought: () => context
                        .read<ShoppingListProvider>()
                        .markRecipeBought(recipeId),
                  ),
                ],
              ),
            ),
    );
  }
}

class _IngredientCartTile extends StatelessWidget {
  const _IngredientCartTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onToggle,
    required this.onRemove,
  });

  final ShoppingItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: AppPad.b12,
      padding: AppPad.h16v12,
      decoration: context.cardBox(),
      child: Row(
        children: [
          // 24px checkbox inside a 44px tap target.
          Pressable(
            onTap: onToggle,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        item.checked ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: item.checked
                          ? AppColors.success
                          : colors.borderDivider,
                      width: 2,
                    ),
                    borderRadius: AppBorderRadius.a6,
                  ),
                  child: item.checked
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w600,
                color: item.checked
                    ? colors.textSecondary
                    : colors.textPrimary,
                decoration:
                    item.checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
          SizedBox(
            width: 30,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrement),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: colors.textDisabled,
            onPressed: onRemove,
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // 30px visual inside a 44px tap target.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.elevated,
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderDivider),
            ),
            child: Icon(icon, size: 16, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryBar extends StatelessWidget {
  const _OrderSummaryBar({
    required this.totalCount,
    required this.boughtCount,
    required this.onMarkBought,
  });

  final int totalCount;
  final int boughtCount;
  final VoidCallback onMarkBought;

  @override
  Widget build(BuildContext context) {
    final allBought = boughtCount >= totalCount && totalCount > 0;

    final colors = context.appColors;

    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(top: BorderSide(color: colors.borderDivider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'shopping_list.order_info'.tr(),
                style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'shopping_list.bought_of_total'.tr(namedArgs: {
                  'bought': '$boughtCount',
                  'total': '$totalCount',
                }),
                style: context.themed(
                  AppTextStyles.s14,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          AppGap.h12,
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: allBought ? null : onMarkBought,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(
                allBought
                    ? 'shopping_list.all_bought'.tr()
                    : 'shopping_list.mark_all_bought'.tr(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.success,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.a14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
