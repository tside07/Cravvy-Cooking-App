import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_plan.dart';

class PlanCardWidget extends StatelessWidget {
  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Selected cards use the fixed light `primaryLight` surface in both themes,
    // so their text must stay dark; unselected cards follow the theme.
    final nameColor = isSelected ? AppColors.textPrimary : colors.textPrimary;
    final noteColor =
        isSelected ? AppColors.textSecondary : colors.textSecondary;
    return Padding(
      padding: AppPad.b10,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          padding: AppPad.a16,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : colors.cardSurface,
            borderRadius: AppBorderRadius.card,
            border: Border.all(
              color: isSelected ? AppColors.primary : colors.borderDivider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? AppShadows.e2Of(Theme.of(context).brightness)
                : const [],
          ),
          child: Row(
            children: [
              // Radio circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : colors.borderDivider,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              AppGap.w14,

              // Name + note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: AppTextStyles.s14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: nameColor,
                      ),
                    ),
                    AppGap.h2,
                    Text(
                      plan.priceNote,
                      style: AppTextStyles.s12.copyWith(color: noteColor),
                    ),
                  ],
                ),
              ),

              AppGap.w8,

              // Savings badge (above) + price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plan.badge != null) ...[
                    Container(
                      padding: AppPad.h8v2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppBorderRadius.a20,
                      ),
                      child: Text(
                        plan.badge!,
                        style: AppTextStyles.s10.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppGap.h6,
                  ],
                  Text(
                    plan.priceLabel,
                    style: AppTextStyles.s16.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
