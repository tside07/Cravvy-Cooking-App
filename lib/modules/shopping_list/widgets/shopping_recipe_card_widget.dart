import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

/// Tappable recipe summary card in the cart list.
class ShoppingRecipeCardWidget extends StatelessWidget {
  const ShoppingRecipeCardWidget({
    super.key,
    required this.recipeName,
    required this.totalCount,
    required this.checkedCount,
    required this.onTap,
    required this.onRemove,
  });

  final String recipeName;
  final int totalCount;
  final int checkedCount;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final remaining = totalCount - checkedCount;
    final allDone = remaining <= 0 && totalCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppPad.h16v14,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: allDone
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.primaryLight,
                    borderRadius: AppBorderRadius.a12,
                  ),
                  child: Icon(
                    allDone
                        ? Icons.check_circle_rounded
                        : Icons.shopping_basket_outlined,
                    color: allDone ? AppColors.success : AppColors.primary,
                    size: 22,
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        allDone
                            ? 'shopping_list.all_bought'.tr()
                            : 'shopping_list.remaining_count'.tr(
                                namedArgs: {'n': '$remaining'},
                              ),
                        style: AppTextStyles.s12.copyWith(
                          color: allDone
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.textHint,
                  onPressed: onRemove,
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
