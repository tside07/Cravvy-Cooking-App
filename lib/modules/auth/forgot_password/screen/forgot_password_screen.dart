import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/init.dart';import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_form_fields_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/icon_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/back_to_login_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/forgot_password/widgets/note_box_widget.dart';
import 'package:cravvy_cooking_app/modules/widgets/common/cravvy_button.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetOtp(email);

    if (!mounted) return;

    if (success) {
      context.push(AppRouter.otp, extra: email);
    } else {
      final error = localizeMessage(auth.errorMessage ?? 'auth.otp_failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: AppTextStyles.s14.copyWith(color: AppColors.white),
          ),          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreAuthScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const PreAuthBackButton(),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => _Body(
            formKey: _formKey,
            emailController: _emailController,
            isLoading: auth.status == AuthStatus.loading,
            onSubmit: _sendOtp,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 768 ? 32.0 : 24.0;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppGap.h16,
                    const IconSectionWidget(icon: Icons.mail_outline_rounded),
                    AppGap.h28,
                    Text(
                      'auth.forgot_title'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PreAuthTheme.textPrimary,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h12,
                    Text(
                      'auth.forgot_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s15.copyWith(
                        color: PreAuthTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    AppGap.h36,
                    AuthFormFieldsWidget(
                      preAuth: true,
                      fields: [
                        AuthFormFieldConfig(
                          hint: 'auth.email_hint'.tr(),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'auth.val_email_required'.tr();
                            }
                            if (!v.contains('@')) {
                              return 'auth.val_email_invalid'.tr();
                            }
                            return null;
                          },
                        ),                      ],
                    ),
                    AppGap.h28,
                    CravvyButton(
                      label: 'auth.send_otp'.tr(),
                      isLoading: isLoading,
                      onTap: onSubmit,
                    ),
                    AppGap.h16,
                    const BackToLoginWidget(),
                    AppGap.h24,
                    const NoteBoxWidget(),
                    AppGap.h24,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}