import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ShoppingBottomBarWidget extends StatelessWidget {
  final int checkedCount;
  final VoidCallback onClearChecked;

  const ShoppingBottomBarWidget({
    super.key,
    required this.checkedCount,
    required this.onClearChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onClearChecked,
          icon: const Icon(Icons.done_all_rounded, size: 18),
          label: Text(
            'shopping_list.clear_checked_count'.tr(
              namedArgs: {'count': checkedCount.toString()},
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.a14,
            ),
          ),
        ),
      ),
    );
  }
}
