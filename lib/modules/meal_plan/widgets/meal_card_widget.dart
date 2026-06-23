// lib/modules/meal_plan/widgets/meal_card_widget.dart
//
// THAY ĐỔI: Nút "Swap" trong header bỏ đi,
// thay bằng icon nhỏ góc phải trong content row (như ảnh mẫu).
// Icon xóa vẫn giữ nhưng chuyển vào menu nhỏ để không chiếm chỗ.

import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

class MealCardWidget extends StatelessWidget {
  const MealCardWidget({
    super.key,
    required this.meal,
    required this.onToggle,
    required this.onSwap,
    required this.onRemove,
  });

  final Meal meal;
  final VoidCallback onToggle;
  final VoidCallback onSwap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppPad.b12,
      child: PressableCard(
        onTap: () => context.push(AppRouter.mealDetail, extra: meal),
        radius: 12,
        // Logged meals keep a success-tinted outline; otherwise rely on shadow
        // (light) / hairline border (dark) like the rest of the Soft UI cards.
        border: meal.isLogged
            ? Border.all(color: AppColors.success.withValues(alpha: 0.35))
            : (isDark ? Border.all(color: colors.borderDivider) : null),
        child: Row(
          children: [
            // ── Ảnh món ăn ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: meal.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: meal.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ImagePlaceholder(meal.type),
                      errorWidget: (_, __, ___) => _ImagePlaceholder(meal.type),
                    )
                  : _ImagePlaceholder(meal.type),
            ),

            // ── Nội dung ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label bữa (BREAKFAST / LUNCH / ...)
                    Row(
                      children: [
                        Icon(
                          meal.type.icon,
                          size: 13,
                          color: meal.type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meal.type.localizedLabel.toUpperCase(),
                          style: AppTextStyles.s10.copyWith(
                            fontWeight: FontWeight.w700,
                            color: meal.type.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Tên món
                    Text(
                      meal.name,
                      style: context.themed(
                        AppTextStyles.s14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Cal + time
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${meal.calories} ${'meal_plan.calories_unit'.tr()}',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${meal.prepTime}${'meal_plan.minutes_short'.tr()}',
                          style: AppTextStyles.s12.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Macros
                    Row(
                      children: [
                        _MacroPill(
                          '${'meal_plan.macro_protein_short'.tr()} ${meal.protein}g',
                          AppColors.secondaryLight,
                          AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 4),
                        _MacroPill(
                          '${'meal_plan.macro_carbs_short'.tr()} ${meal.carbs}g',
                          const Color(0xFFFFFAE6),
                          AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        _MacroPill(
                          '${'meal_plan.macro_fat_short'.tr()} ${meal.fat}g',
                          AppColors.primaryLight,
                          AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Action column: log check + edit icon ─────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Log toggle — 32px visual inside a 44px tap target.
                  Pressable(
                    onTap: onToggle,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: meal.isLogged
                                ? AppColors.success
                                : colors.elevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: meal.isLogged
                                  ? AppColors.success
                                  : colors.borderDivider,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: meal.isLogged
                                ? Colors.white
                                : colors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Đổi món — tap mở sheet chọn món khác (như design mẫu).
                  Pressable(
                    onTap: onSwap,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: AppBorderRadius.chip,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ─── Empty slot (giữ nguyên) ──────────────────────────────────────────────────
class EmptyMealSlotCard extends StatelessWidget {
  const EmptyMealSlotCard({
    super.key,
    required this.mealType,
    required this.onAdd,
  });

  final MealType mealType;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: context.cardBox(radius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: mealType.lightColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(mealType.icon, size: 16, color: mealType.color),
              ),
            ),
            AppGap.w10,
            Text(
              'meal_plan.add_meal'.tr(
                namedArgs: {'meal': mealType.localizedLabel},
              ),
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppGap.w8,
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(this.type);
  final MealType type;

  @override
  Widget build(BuildContext context) => Container(
    width: 90,
    height: 90,
    color: type.lightColor,
    child: Center(child: Icon(type.icon, size: 32, color: type.color)),
  );
}

class _MacroPill extends StatelessWidget {
  const _MacroPill(this.label, this.bg, this.textColor);
  final String label;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: AppTextStyles.s10.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    ),
  );
}
