import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_plan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Payment sheet for [plan].
///
/// - PAID plan: QR MoMo thật + nội dung CK định danh ("[Họ tên] + chuyển tiền
///   gói premium") + nút Sao chép. Người dùng chuyển khoản, chụp bill rồi GỬI vào
///   Fanpage Messenger kèm email; admin xác minh & kích hoạt thủ công. KHÔNG cấp
///   premium tại client (đúng mô hình duyệt thủ công).
/// - TRIAL: vẫn kích hoạt ngay 14 ngày ([AuthProvider.startPremiumTrial]).
///
/// Trả `true` chỉ khi TRIAL được kích hoạt. Paid trả `null/false` (sheet tự hiển
/// thị trạng thái "chờ duyệt").
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
  bool _submitted = false; // paid: đã bấm "Gửi bill" -> hiện màn chờ duyệt

  /// Nội dung chuyển khoản — định danh người trả để admin đối chiếu bill.
  String get _transferNote {
    if (widget.isTrial) return 'CRAVVY ${widget.plan.id.toUpperCase()}';
    final name = (context.read<AuthProvider>().user?.fullName ?? '').trim();
    final who = name.isEmpty ? 'Cravvy' : name;
    return '$who + chuyển tiền gói premium';
  }

  /// Email tài khoản — KHOÁ ĐỐI CHIẾU admin dùng để kích hoạt Premium thủ công.
  String get _accountEmail =>
      (context.read<AuthProvider>().user?.email ?? '').trim();

  /// Handle Fanpage dạng đọc được (vd `m.me/cravvycooking.vn`) — hiển thị phòng
  /// khi deep-link mở hụt.
  String get _fanpageHandle =>
      AppConst.fanpageMessengerUrl.replaceFirst(RegExp(r'^https?://'), '');

  /// PAID: nội dung dán sẵn vào Messenger. Email dẫn đầu vì là khoá đối chiếu;
  /// `m.me` không tự điền được ô chat nên ta copy nguyên đoạn này vào clipboard.
  String get _activationMessage {
    final email = _accountEmail;
    final emailLine =
        email.isEmpty ? 'subscription.qr.msg_email_missing'.tr() : email;
    return 'subscription.qr.msg_template'.tr(
      namedArgs: {'email': emailLine, 'plan': widget.plan.name},
    );
  }

  /// TRIAL: kích hoạt ngay (miễn phí). Chỉ dùng cho nhánh trial.
  Future<void> _startTrial() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.startPremiumTrial();
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

  void _copyNote() => _copy(_transferNote, 'subscription.qr.copied'.tr());

  void _copyEmail() => _copy(_accountEmail, 'subscription.qr.email_copied'.tr());

  void _copyActivationMessage() =>
      _copy(_activationMessage, 'subscription.qr.msg_copied'.tr());

  void _copy(String text, String confirm) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirm),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// PAID: copy sẵn nội dung gửi → mở Fanpage (ưu tiên Messenger) → màn hướng
  /// dẫn bước cuối (có nút mở lại + copy lại). KHÔNG cấp premium ở đây.
  Future<void> _submitBill() async {
    setState(() => _loading = true);
    await Clipboard.setData(ClipboardData(text: _activationMessage));
    final opened = await _openFanpage();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _submitted = true;
    });
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('subscription.qr.open_failed'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Trả `true` nếu mở được Messenger hoặc trang Fanpage; `false` nếu cả hai fail.
  Future<bool> _openFanpage() async {
    for (final url in [AppConst.fanpageMessengerUrl, AppConst.fanpageUrl]) {
      try {
        final launched = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } catch (_) {
        // thử link kế tiếp
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale; // re-localize nếu đổi ngôn ngữ khi sheet đang mở
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
              child: _submitted
                  ? _PendingView(
                      messengerHandle: _fanpageHandle,
                      onClose: () => Navigator.of(context).pop(),
                      onReopen: () => _openFanpage(),
                      onCopyMessage: _copyActivationMessage,
                    )
                  : Column(
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

                        _TransferDetails(
                          plan: widget.plan,
                          note: _transferNote,
                          onCopy: widget.isTrial ? null : _copyNote,
                          email: widget.isTrial || _accountEmail.isEmpty
                              ? null
                              : _accountEmail,
                          onCopyEmail: widget.isTrial || _accountEmail.isEmpty
                              ? null
                              : _copyEmail,
                        ),

                        // PAID nhưng tài khoản chưa có email → admin không đối
                        // chiếu được; cảnh báo trước khi thanh toán.
                        if (!widget.isTrial && _accountEmail.isEmpty) ...[
                          AppGap.h12,
                          const _NoEmailWarning(),
                        ],

                        // PAID: hướng dẫn 3 bước gửi bill
                        if (!widget.isTrial) ...[
                          AppGap.h16,
                          const _PaidSteps(),
                        ],
                      ],
                    ),
            ),
          ),

          if (!_submitted)
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
                      onPressed: _loading
                          ? null
                          : (widget.isTrial ? _startTrial : _submitBill),
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
                              widget.isTrial
                                  ? 'subscription.qr.paid_confirm'.tr()
                                  : 'subscription.qr.send_bill'.tr(),
                              style: AppTextStyles.s16.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    widget.isTrial
                        ? 'subscription.qr.disclaimer'.tr()
                        : 'subscription.qr.paid_disclaimer'.tr(),
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
  const _TransferDetails({
    required this.plan,
    required this.note,
    this.onCopy,
    this.email,
    this.onCopyEmail,
  });

  final SubscriptionPlan plan;
  final String note;
  final VoidCallback? onCopy;

  /// PAID: email tài khoản (khoá đối chiếu). Null = ẩn dòng (trial / chưa có).
  final String? email;
  final VoidCallback? onCopyEmail;

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
          if (email != null)
            _row(
              context,
              'subscription.qr.account_email'.tr(),
              email!,
              onCopy: onCopyEmail,
            ),
          _row(
            context,
            'subscription.qr.note'.tr(),
            note,
            onCopy: onCopy,
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
    VoidCallback? onCopy,
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.themed(
                AppTextStyles.s13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onCopy != null) ...[
            AppGap.w8,
            InkWell(
              onTap: onCopy,
              borderRadius: AppBorderRadius.a8,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// PAID: 3 bước gửi bill để admin duyệt thủ công.
class _PaidSteps extends StatelessWidget {
  const _PaidSteps();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: AppBorderRadius.card,
        border: Border.all(color: colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _step(context, '1', 'subscription.qr.step1'.tr()),
          AppGap.h10,
          _step(context, '2', 'subscription.qr.step2'.tr()),
          AppGap.h10,
          _step(context, '3', 'subscription.qr.step3'.tr()),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, String n, String text) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            n,
            style: AppTextStyles.s12.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppGap.w12,
        Expanded(
          child: Text(
            text,
            style: context.themed(AppTextStyles.s13, color: colors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// PAID: bước cuối sau khi bấm "Mở Messenger gửi bill". Nội dung gửi đã được
/// copy sẵn vào clipboard; màn này cung cấp nút mở lại Messenger / copy lại và
/// hiển thị handle Fanpage (selectable) phòng khi deep-link mở hụt.
class _PendingView extends StatelessWidget {
  const _PendingView({
    required this.messengerHandle,
    required this.onClose,
    required this.onReopen,
    required this.onCopyMessage,
  });

  final String messengerHandle;
  final VoidCallback onClose;
  final VoidCallback onReopen;
  final VoidCallback onCopyMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppGap.h12,
        Icon(Icons.send_rounded, size: 56, color: AppColors.primary),
        AppGap.h16,
        Text(
          'subscription.qr.pending_title'.tr(),
          textAlign: TextAlign.center,
          style: context.themed(AppTextStyles.h2, fontWeight: FontWeight.w700)
              .copyWith(fontSize: 18),
        ),
        AppGap.h8,
        Text(
          'subscription.qr.pending_body'.tr(),
          textAlign: TextAlign.center,
          style: context.themed(AppTextStyles.s14, color: colors.textSecondary),
        ),
        AppGap.h16,
        // Handle Fanpage — đọc/copy được kể cả khi không mở được Messenger.
        Container(
          padding: AppPad.h16v12,
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: AppBorderRadius.card,
            border: Border.all(color: colors.borderDivider),
          ),
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: colors.textSecondary),
              AppGap.w8,
              Expanded(
                child: SelectableText(
                  messengerHandle,
                  style: context.themed(
                    AppTextStyles.s13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppGap.h20,
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onReopen,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(
              'subscription.qr.reopen_messenger'.tr(),
              style: AppTextStyles.s16.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.button,
              ),
            ),
          ),
        ),
        AppGap.h8,
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onCopyMessage,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text('subscription.qr.copy_message'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: colors.borderDivider),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.button,
              ),
            ),
          ),
        ),
        AppGap.h4,
        TextButton(
          onPressed: onClose,
          child: Text(
            'subscription.qr.pending_close'.tr(),
            style: context.themed(
              AppTextStyles.s14,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// PAID: tài khoản chưa có email (vd OAuth chưa backfill) → admin không đối
/// chiếu được giao dịch. Cảnh báo user thêm email trước khi thanh toán.
class _NoEmailWarning extends StatelessWidget {
  const _NoEmailWarning();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: AppBorderRadius.card,
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.error),
          AppGap.w8,
          Expanded(
            child: Text(
              'subscription.qr.no_email'.tr(),
              style: context.themed(
                AppTextStyles.s13,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
