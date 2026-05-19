import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ShoppingHeaderWidget extends StatelessWidget {
  final int checkedCount;
  final int totalCount;
  final double progress;
  final VoidCallback onShare;
  final VoidCallback onClearChecked;
  final VoidCallback onClearAll;

  const ShoppingHeaderWidget({
    super.key,
    required this.checkedCount,
    required this.totalCount,
    required this.progress,
    required this.onShare,
    required this.onClearChecked,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'shopping_list.title'.tr(),
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'shopping_list.item_count'.tr(
                        namedArgs: {
                          'checked': checkedCount.toString(),
                          'total': totalCount.toString(),
                        },
                      ),
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: onShare,
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'clear_checked') onClearChecked();
                  if (v == 'clear_all') onClearAll();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'clear_checked',
                    child: Text('shopping_list.clear_checked'.tr()),
                  ),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Text('shopping_list.clear_all'.tr()),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          AppGap.h10,
          ClipRRect(
            borderRadius: AppBorderRadius.a4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.success,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
