import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/modules/meal_detail/provider/meal_detail_provider.dart';

/// "Servings" row with decrement / count / increment controls.
class MealDetailServingsWidget extends StatelessWidget {
  const MealDetailServingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<MealDetailProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 12,
            ),
            child: Row(
              children: [
                Text(
                  'meal_detail.servings'.tr(),
                  style: AppTextStyles.s16.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _StepButton(
                  icon: Icons.remove,
                  onTap: provider.decrementServings,
                ),
                Padding(
                  padding: AppPad.h16,
                  child: Text(
                    '${provider.servings}',
                    style: AppTextStyles.s18.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add,
                  onTap: provider.incrementServings,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
