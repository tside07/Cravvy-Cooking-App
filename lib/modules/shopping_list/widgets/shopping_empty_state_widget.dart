import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ShoppingEmptyStateWidget extends StatelessWidget {
  const ShoppingEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'shopping_list.title'.tr(),
          style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppPad.h32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 44,
                  color: AppColors.textHint,
                ),
              ),
              AppGap.h24,
              Text(
                'shopping_list.empty_title'.tr(),
                style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),
              ),
              AppGap.h8,
              Text(
                'shopping_list.empty_desc'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppGap.h24,
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.app),
                icon: const Icon(Icons.search_rounded),
                label: Text('shopping_list.browse_recipes'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.a14,
                  ),
                  padding: AppPad.h24v14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
