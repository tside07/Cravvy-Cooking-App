import 'package:cravvy_cooking_app/init.dart';
// import 'package:cravvy_cooking_app/modules/shopping_list/screen/shopping_list_screen.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/widgets/shopping_item_tile_widget.dart';

class ShoppingRecipeGroupWidget extends StatelessWidget {
  final String recipeName;
  final List<ShoppingItem> items;
  final void Function(String id) onToggle;
  final void Function(String id) onRemove;

  const ShoppingRecipeGroupWidget({
    super.key,
    required this.recipeName,
    required this.items,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPad.h8,
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              AppGap.w8,
              Text(
                recipeName,
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.a16,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return ShoppingItemTileWidget(
                item: item,
                isLast: isLast,
                onToggle: () => onToggle(item.id),
                onRemove: () => onRemove(item.id),
              );
            }).toList(),
          ),
        ),
        AppGap.h12,
      ],
    );
  }
}
