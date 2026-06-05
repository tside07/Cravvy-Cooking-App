import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_empty_state_widget.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_recipe_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShoppingListView();
  }
}

class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView();

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final provider = context.watch<ShoppingListProvider>();

    if (!provider.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.isEmpty) return const ShoppingEmptyStateWidget();

    final recipeIds = provider.recipeIds;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'shopping_list.cart_title'.tr(),
          style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.textPrimary),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: AppPad.h16v12,
          itemCount: recipeIds.length,
          itemBuilder: (context, index) {
            final recipeId = recipeIds[index];
            return ShoppingRecipeCardWidget(
              recipeName: provider.recipeNameOf(recipeId),
              totalCount: provider.totalCountForRecipe(recipeId),
              checkedCount: provider.checkedCountForRecipe(recipeId),
              onTap: () => context.push(
                AppRouter.shoppingRecipeDetail,
                extra: recipeId,
              ),
              onRemove: () =>
                  context.read<ShoppingListProvider>().removeRecipe(recipeId),
            );
          },
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
