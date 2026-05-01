import 'dart:async';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_auth_app_bar.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_header_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/widgets/icon_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/widgets/otp_input_row_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/widgets/resend_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/widgets/help_text_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _otpLength = 6;
  static const _countdownSeconds = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _countdownSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetOtp(widget.email);
    if (!mounted) return;
    if (success) {
      setState(() => _secondsLeft = _countdownSeconds);
      _startCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Error Occurred. Unable to resend OTP',
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final name = parts[0];
    final masked = name.length > 2
        ? '${name.substring(0, 2)}***'
        : '${name[0]}***';
    return '$masked@${parts[1]}';
  }

  String get _countdownLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (_otpValue.length < _otpLength) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(email: widget.email, token: _otpValue);

    if (!mounted) return;

    if (success) {
      // OTP đúng → vào reset password
      context.push(AppRouter.resetPassword, extra: widget.email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Invalid OTP',
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      // Clear input
      for (final c in _controllers) c.clear();
      if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAuthAppBar(),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => _Body(
            controllers: _controllers,
            focusNodes: _focusNodes,
            maskedEmail: _maskedEmail,
            countdownLabel: _countdownLabel,
            secondsLeft: _secondsLeft,
            isLoading: auth.status == AuthStatus.loading,
            isComplete: _otpValue.length == _otpLength,
            onChanged: (_) => setState(() {}),
            onResend: _resend,
            onVerify: _verify,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.controllers,
    required this.focusNodes,
    required this.maskedEmail,
    required this.countdownLabel,
    required this.secondsLeft,
    required this.isLoading,
    required this.isComplete,
    required this.onChanged,
    required this.onResend,
    required this.onVerify,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String maskedEmail;
  final String countdownLabel;
  final int secondsLeft;
  final bool isLoading;
  final bool isComplete;
  final ValueChanged<String> onChanged;
  final VoidCallback onResend;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppPad.h24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppGap.h16,
          const IconSectionWidget(icon: Icons.verified_user_outlined),
          AppGap.h28,
          AuthHeaderWidget(
            title: 'Verify Your Identity',
            subtitle: 'We have sent a 6-digit OTP code to $maskedEmail',
            textAlign: TextAlign.center,
          ),
          AppGap.h40,
          OtpInputRowWidget(
            controllers: controllers,
            focusNodes: focusNodes,
            onChanged: onChanged,
          ),
          AppGap.h24,
          ResendSectionWidget(
            secondsLeft: secondsLeft,
            countdownLabel: countdownLabel,
            onResend: onResend,
          ),
          AppGap.h36,
          CravvyButton(
            label: 'Verify',
            isLoading: isLoading,
            onTap: isComplete ? onVerify : null,
            backgroundColor: isComplete
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          AppGap.h20,
          const HelpTextWidget(),
          AppGap.h24,
        ],
      ),
    );
  }
}
