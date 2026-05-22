// lib/modules/meal_plan/widgets/meal_card_widget.dart
//
// THAY ĐỔI: Nút "Swap" trong header bỏ đi,
// thay bằng icon nhỏ góc phải trong content row (như ảnh mẫu).
// Icon xóa vẫn giữ nhưng chuyển vào menu nhỏ để không chiếm chỗ.

import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return GestureDetector(
      onTap: () => context.push(AppRouter.mealDetail, extra: meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.a16,
          border: Border.all(
            color: meal.isLogged
                ? AppColors.success.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // ── Ảnh món ăn ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
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
                        Text(
                          meal.type.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meal.type.label.toUpperCase(),
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
                      style: AppTextStyles.s14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
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
                          '${meal.calories} cal',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${meal.prepTime}m',
                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Macros
                    Row(
                      children: [
                        _MacroPill(
                          'P ${meal.protein}g',
                          AppColors.secondaryLight,
                          AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 4),
                        _MacroPill(
                          'C ${meal.carbs}g',
                          const Color(0xFFFFFAE6),
                          AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        _MacroPill(
                          'F ${meal.fat}g',
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
                  // Log toggle
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: meal.isLogged
                            ? AppColors.success
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: meal.isLogged
                              ? AppColors.success
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: meal.isLogged
                            ? Colors.white
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Edit/swap icon — compact, góc phải như ảnh mẫu
                  GestureDetector(
                    onTap: () => _showActionMenu(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
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

  // Tap icon edit → menu nhỏ: Đổi món / Xóa
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Tên món
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                meal.name,
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),
            // Đổi món
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              title: Text(
                'Đổi món',
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Chọn món khác cho slot này',
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onSwap();
              },
            ),
            // Xóa
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              title: Text(
                'Xóa khỏi kế hoạch',
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmRemove(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xóa bữa ăn?',
          style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Xóa ${meal.name} khỏi kế hoạch?',
          style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove();
            },
            child: Text(
              'Xóa',
              style: AppTextStyles.s14.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.a16,
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
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
                child: Text(
                  mealType.emoji,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            AppGap.w10,
            Text(
              'Thêm ${mealType.label}',
              style: AppTextStyles.s14.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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
    child: Center(
      child: Text(type.emoji, style: const TextStyle(fontSize: 28)),
    ),
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
