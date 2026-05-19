import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_header_widget.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_recipe_group_widget.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_empty_state_widget.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_bottom_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingListProvider(),
      child: const _ShoppingListView(),
    );
  }
}

class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListProvider>();

    if (provider.isEmpty) return const ShoppingEmptyStateWidget();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ShoppingHeaderWidget(
              checkedCount: provider.checkedCount,
              totalCount: provider.totalCount,
              progress: provider.progress,
              onShare: () => _showShareDialog(context),
              onClearChecked: () =>
                  context.read<ShoppingListProvider>().clearChecked(),
              onClearAll: () => _showClearAllDialog(context),
            ),
            Expanded(
              child: ListView.builder(
                padding: AppPad.h16v12,
                itemCount: provider.grouped.length,
                itemBuilder: (context, groupIndex) {
                  final recipeId = provider.grouped.keys.elementAt(groupIndex);
                  final items = provider.grouped[recipeId]!;
                  final recipeName = provider.recipeNameOf(recipeId);

                  return ShoppingRecipeGroupWidget(
                    recipeName: recipeName,
                    items: items,
                    onToggle: (id) =>
                        context.read<ShoppingListProvider>().toggle(id),
                    onRemove: (id) =>
                        context.read<ShoppingListProvider>().remove(id),
                  );
                },
              ),
            ),
            if (provider.checkedCount > 0)
              ShoppingBottomBarWidget(
                checkedCount: provider.checkedCount,
                onClearChecked: () =>
                    context.read<ShoppingListProvider>().clearChecked(),
              ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: AppPad.a24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'shopping_list.share_title'.tr(),
              style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),
            ),
            AppGap.h16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.copy_rounded),
                label: Text('shopping_list.copy_clipboard'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.a12,
                  ),
                ),
              ),
            ),
            AppGap.h8,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('common.cancel'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a20),
        title: Text('shopping_list.clear_all_title'.tr()),
        content: Text('shopping_list.clear_all_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ShoppingListProvider>().clearAll();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'shopping_list.clear_all'.tr(),
              style: AppTextStyles.s16.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
