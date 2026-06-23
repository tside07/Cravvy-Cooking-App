import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_plan.dart';
import 'package:cravvy_cooking_app/modules/subscription/provider/subscription_provider.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/plan_card_widget.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/highlight_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/feature_row_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/payment_qr_sheet.dart';
import 'package:cravvy_cooking_app/modules/subscription/widgets/trial_auto_cancel_notice_widget.dart';
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

class _SubscriptionView extends StatefulWidget {
  const _SubscriptionView();

  @override
  State<_SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<_SubscriptionView> {
  @override
  void initState() {
    super.initState();
    // Auto-cancel a lapsed trial when the user lands here (this screen is the
    // only place a trial can be (re)activated).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().checkTrialExpiry();
    });
  }

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
                    style: context.themed(
                      AppTextStyles.s18,
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
                          AppGap.h16,
                          Text(
                            'subscription.hero_title'.tr(),
                            textAlign: TextAlign.center,
                            style: context
                                .themed(
                                  AppTextStyles.s20,
                                  fontWeight: FontWeight.w800,
                                )
                                .copyWith(fontSize: 28),
                          ),
                          AppGap.h8,
                          Text(
                            'subscription.hero_subtitle'.tr(),
                            textAlign: TextAlign.center,
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
                      style: context.themed(
                        AppTextStyles.s16,
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
                      style: context.themed(
                        AppTextStyles.s16,
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
                                      style: context.themed(
                                        AppTextStyles.s12,
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
            _CtaBar(provider: provider, auth: auth, plans: plans),
          ],
        ),
      ),
    );
  }
}

/// Bottom action bar driven by both the selected plan and the account's trial
/// eligibility:
/// - eligible + paid plan  → auto-cancel notice + "Continue" → payment QR
/// - eligible + free plan  → disabled "You're on Free"
/// - already premium/trial → disabled "Current plan"
/// - trial already used     → disabled "Trial used"
class _CtaBar extends StatelessWidget {
  const _CtaBar({
    required this.provider,
    required this.auth,
    required this.plans,
  });

  final SubscriptionProvider provider;
  final AuthProvider auth;
  final List<SubscriptionPlan> plans;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final selected = plans.firstWhere(
      (p) => p.id == provider.selectedPlanId,
      orElse: () => plans.first,
    );
    final isPaidSelected = selected.id != PlanLimits.tierFree;

    String label;
    VoidCallback? onTap;
    bool showNotice = false;

    if (auth.canStartPremiumTrial) {
      // First-timer: pay → 14-day trial (auto-cancels).
      if (isPaidSelected) {
        label = 'subscription.continue'.tr();
        onTap = () => _onContinue(context, selected, isTrial: true);
        showNotice = true;
      } else {
        label = 'subscription.free_current'.tr();
        onTap = null;
      }
    } else if (auth.canUpgradeToPaid) {
      // Trial already used / lapsed: pay → real Premium (no auto-cancel).
      if (isPaidSelected) {
        label = 'subscription.upgrade_now'.tr();
        onTap = () => _onContinue(context, selected, isTrial: false);
      } else {
        label = 'subscription.free_current'.tr();
        onTap = null;
      }
    } else {
      // Currently Premium.
      label = 'subscription.current_plan'.tr();
      onTap = null;
    }

    final enabled = onTap != null;

    return Container(
      padding: AppPad.a20,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(top: BorderSide(color: colors.borderDivider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showNotice) ...[
            const TrialAutoCancelNoticeWidget(),
            AppGap.h12,
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: colors.elevated,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.button,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.s16.copyWith(
                  color: enabled ? colors.onPrimary : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          AppGap.h8,
          Text(
            'subscription.cancel_note'.tr(),
            textAlign: TextAlign.center,
            style: context.themed(
              AppTextStyles.s12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue(
    BuildContext context,
    SubscriptionPlan plan, {
    required bool isTrial,
  }) async {
    final ok = await showPaymentQrSheet(
      context,
      plan: plan,
      isTrial: isTrial,
    );
    if (ok != true || !context.mounted) return;
    if (isTrial) {
      // Celebratory trial-unlocked screen.
      context.push(AppRouter.trialActivation);
    } else {
      // Real purchase: stay here (CTA flips to "Current plan") + confirm.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('subscription.upgrade_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
