import 'package:cravvy_cooking_app/init.dart';
// import 'package:cravvy_cooking_app/modules/shopping_list/screen/shopping_list_screen.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/model/shopping_item.dart';

class ShoppingItemTileWidget extends StatelessWidget {
  final ShoppingItem item;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const ShoppingItemTileWidget({
    super.key,
    required this.item,
    required this.isLast,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(16),
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: AppPad.h16v14,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.checked
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: item.checked
                          ? AppColors.success
                          : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: AppBorderRadius.a6,
                  ),
                  child: item.checked
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                AppGap.w12,
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTextStyles.s14.copyWith(
                      color: item.checked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: item.checked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onRemove,
                  color: AppColors.textHint,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 52, color: AppColors.border),
      ],
    );
  }
}
