import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/provider/subscription_provider.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/plan_card_widget.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/highlight_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/feature_row_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: const _SubscriptionView(),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final _ = context.locale;
    final provider = context.watch<SubscriptionProvider>();
    final auth = context.watch<AuthProvider>();
    final plans = SubscriptionProvider.plans();
    final highlights = SubscriptionProvider.highlights();
    final features = SubscriptionProvider.featureRows();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(
                color: colors.cardSurface,
                border: Border(bottom: BorderSide(color: colors.borderDivider)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'subscription.title'.tr(),
                    style: AppTextStyles.s18.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: AppPad.a20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          AppGap.w16,
                          Text(
                            'subscription.hero_title'.tr(),
                            style: AppTextStyles.s20.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                          ),
                          AppGap.h8,
                          Text(
                            'subscription.hero_subtitle'.tr(),
                            style: context.themed(
                              AppTextStyles.s14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.h28,

                    // ── Plan cards ────────────────────────────────────────
                    ...plans.map(
                      (plan) => PlanCardWidget(
                        plan: plan,
                        isSelected: provider.selectedPlanId == plan.id,
                        onTap: () => provider.selectPlan(plan.id),
                      ),
                    ),
                    AppGap.h24,

                    // ── Highlights ────────────────────────────────────────
                    Text(
                      'subscription.what_you_get'.tr(),
                      style: AppTextStyles.s16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppGap.h12,
                    ...highlights.map(
                      (h) => Padding(
                        padding: AppPad.b10,
                        child: HighlightTileWidget(highlight: h),
                      ),
                    ),
                    AppGap.h24,

                    // ── Comparison table ──────────────────────────────────
                    Text(
                      'subscription.compare_plans'.tr(),
                      style: AppTextStyles.s16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppGap.h12,
                    Container(
                      decoration: BoxDecoration(
                        color: colors.cardSurface,
                        borderRadius: AppBorderRadius.card,
                        boxShadow: AppShadows.e1Of(
                          Theme.of(context).brightness,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: AppPad.h16v12,
                            decoration: BoxDecoration(
                              color: colors.elevated,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'subscription.table.feature'.tr(),
                                    style: context.themed(
                                      AppTextStyles.s12,
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'subscription.table.free'.tr(),
                                      style: AppTextStyles.s12.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'subscription.table.premium'.tr(),
                                      style: AppTextStyles.s12.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...features.asMap().entries.map(
                            (e) => FeatureRowTileWidget(
                              row: e.value,
                              isLast: e.key == features.length - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.h24,
                  ],
                ),
              ),
            ),

            // ── CTA bar ───────────────────────────────────────────────────
            Container(
              padding: AppPad.a20,
              decoration: BoxDecoration(
                color: colors.cardSurface,
                border: Border(top: BorderSide(color: colors.borderDivider)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.canStartPremiumTrial
                          ? () => _onStartTrial(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: colors.elevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                      child: Text(
                        auth.canStartPremiumTrial
                            ? 'subscription.start_trial'.tr()
                            : 'subscription.current_plan'.tr(),
                        style: AppTextStyles.s16.copyWith(
                          color: auth.canStartPremiumTrial
                              ? colors.onPrimary
                              : colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'subscription.cancel_note'.tr(),
                    style: context.themed(
                      AppTextStyles.s12,
                      color: colors.textSecondary,
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

  Future<void> _onStartTrial(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.startPremiumTrial();
    if (!context.mounted) return;
    if (ok) {
      context.push(AppRouter.trialActivation);
      return;
    }
    final msg = auth.errorMessage ?? 'subscription.trial_failed'.tr();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
