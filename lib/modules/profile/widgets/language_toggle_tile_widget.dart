import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageToggleTileWidget extends StatelessWidget {
  const LanguageToggleTileWidget({super.key, this.showDivider = false});

  final bool showDivider;

  static const _locales = [Locale('en', 'US'), Locale('vi', 'VN')];

  static const _labels = {'en': '🇺🇸 English', 'vi': '🇻🇳 Tiếng Việt'};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currentLocale = context.locale;
    final isVi = currentLocale.languageCode == 'vi';

    return Column(
      children: [
        ListTile(
          contentPadding: AppPad.h16v4,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: AppBorderRadius.a10,
            ),
            child: Center(child: Text('🌐', style: AppTextStyles.s18)),
          ),
          title: Text(
            'profile.language'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.textPrimary),
          ),
          trailing: GestureDetector(
            onTap: () {
              final next = isVi ? _locales[0] : _locales[1];
              context.setLocale(next);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorderRadius.a20,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isVi ? '🇻🇳' : '🇺🇸',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isVi ? 'VI' : 'EN',
                    style: AppTextStyles.s12.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) Divider(height: 0.1, color: colors.borderDivider),
      ],
    );
  }
}
