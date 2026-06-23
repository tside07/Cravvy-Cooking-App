import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_plan.dart';
import 'package:easy_localization/easy_localization.dart';

/// Mock payment sheet for [plan]. Shows a placeholder QR + bank-transfer note;
/// tapping "I've paid" activates Premium. When [isTrial] is true it starts the
/// one-time 14-day trial ([AuthProvider.startPremiumTrial]); otherwise it
/// activates a paid plan ([AuthProvider.activatePaidPlan]). Pops `true` on
/// success.
///
/// NOTE: the QR is a static mockup — swap [_MockQrCode] for a real gateway
/// payload (VietQR / PayOS / VNPay) when wiring actual payments.
Future<bool?> showPaymentQrSheet(
  BuildContext context, {
  required SubscriptionPlan plan,
  required bool isTrial,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentQrSheet(plan: plan, isTrial: isTrial),
  );
}

class _PaymentQrSheet extends StatefulWidget {
  const _PaymentQrSheet({required this.plan, required this.isTrial});

  final SubscriptionPlan plan;
  final bool isTrial;

  @override
  State<_PaymentQrSheet> createState() => _PaymentQrSheetState();
}

class _PaymentQrSheetState extends State<_PaymentQrSheet> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = widget.isTrial
        ? await auth.startPremiumTrial()
        : await auth.activatePaidPlan(widget.plan.id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _loading = false);
    final err = localizeMessage(auth.errorMessage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err.isEmpty ? 'subscription.trial_failed'.tr() : err),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.backgroundMain,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppShadows.e3Of(Theme.of(context).brightness),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderDivider,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'subscription.qr.title'.tr(),
                    style: context
                        .themed(AppTextStyles.h2, fontWeight: FontWeight.w700)
                        .copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: colors.textSecondary,
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  // Plan + amount
                  Text(
                    widget.plan.name,
                    style: context.themed(
                      AppTextStyles.s14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    widget.plan.priceLabel,
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.primary,
                      fontSize: 30,
                    ),
                  ),
                  AppGap.h20,

                  const _PaymentQrImage(),
                  AppGap.h12,
                  Text(
                    'subscription.qr.scan_hint'.tr(),
                    textAlign: TextAlign.center,
                    style: context.themed(
                      AppTextStyles.s12,
                      color: colors.textSecondary,
                    ),
                  ),
                  AppGap.h20,

                  // Mock transfer details
                  _TransferDetails(plan: widget.plan),
                ],
              ),
            ),
          ),

          // Footer CTA
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
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
                    onPressed: _loading ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: colors.elevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.button,
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'subscription.qr.paid_confirm'.tr(),
                            style: AppTextStyles.s16.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                AppGap.h8,
                Text(
                  'subscription.qr.disclaimer'.tr(),
                  textAlign: TextAlign.center,
                  style: context.themed(
                    AppTextStyles.s12,
                    color: colors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Real static payment QR (MoMo / VietQR / Napas247). Bundled image at
/// [ImagePath.paymentQrMomo]; falls back to a hint card if the asset is missing
/// so the build never breaks before the file is dropped in.
class _PaymentQrImage extends StatelessWidget {
  const _PaymentQrImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorderRadius.a16,
      child: Image.asset(
        ImagePath.paymentQrMomo,
        width: 260,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _QrFallback(),
      ),
    );
  }
}

class _QrFallback extends StatelessWidget {
  const _QrFallback();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 260,
      height: 260,
      alignment: Alignment.center,
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: colors.borderDivider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 72, color: colors.textDisabled),
          AppGap.h12,
          Text(
            'subscription.qr.missing_asset'.tr(),
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
}

class _TransferDetails extends StatelessWidget {
  const _TransferDetails({required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: AppBorderRadius.card,
        border: Border.all(color: colors.borderDivider),
      ),
      child: Column(
        children: [
          _row(context, 'subscription.qr.amount'.tr(), plan.priceLabel),
          _row(
            context,
            'subscription.qr.note'.tr(),
            'CRAVVY ${plan.id.toUpperCase()}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.themed(
                AppTextStyles.s12,
                color: colors.textSecondary,
              ),
            ),
          ),
          AppGap.w12,
          Text(
            value,
            style: context.themed(
              AppTextStyles.s13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
