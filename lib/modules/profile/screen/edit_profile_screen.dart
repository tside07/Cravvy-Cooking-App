import 'package:flutter/services.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/edit_profile_section_header_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/field_card_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/danger_tile_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/simple_dialog_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late DateTime _birthDate;

  static const int _bioMaxLength = 200;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>();
    _nameCtrl = TextEditingController(text: p.name);
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone);
    _bioCtrl = TextEditingController(text: p.bio);
    _birthDate = p.birthDate;
    _bioCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    HapticFeedback.mediumImpact();

    final auth = context.read<AuthProvider>();
    final ok = await auth.updateDisplayProfile(
      fullName: _nameCtrl.text.trim(),
      birthDate: _birthDate,
      email: _emailCtrl.text.trim(),
    );
    if (!mounted) return;
    if (!ok) {
      final msg = auth.errorMessage ??
          'Cập nhật hồ sơ thất bại. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    context.read<ProfileProvider>().updateLocalProfile(
      phone: _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      birthDate: _birthDate,
    );
    context.pop();
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialogWidget(
        title: 'profile.change_pw'.tr(),
        body: 'profile.change_pw_desc'.tr(),
        confirmLabel: 'common.ok'.tr(),
        onConfirm: () => Navigator.pop(context),
        isDestructive: false,
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    if (!mounted) return;
    if (ok) {
      context.go(AppRouter.onboarding);
      return;
    }
    final msg = auth.errorMessage ?? 'settings.delete_failed'.tr();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialogWidget(
        title: 'profile.delete_acc'.tr(),
        body: 'profile.delete_acc_desc'.tr(),
        confirmLabel: 'common.delete'.tr(),
        onConfirm: () {
          Navigator.pop(context);
          _confirmDeleteAccount();
        },
        isDestructive: true,
      ),
    );
  }

  TextStyle _fieldTextStyle(BuildContext context) =>
      AppTextStyles.s14.copyWith(color: context.appColors.textPrimary);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.year}';

    final profile = context.read<ProfileProvider>();
    final fieldStyle = _fieldTextStyle(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'profile.edit_profile'.tr(),
          style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGap.h16,

              // Avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              profile.initials,
                              style: AppTextStyles.s20.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h8,
                    Text(
                      'profile.change_avatar'.tr(),
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              AppGap.h24,

              EditProfileSectionHeaderWidget(title: 'profile.basic_info'.tr()),
              AppGap.h8,

              FieldCardWidget(
                child: TextFormField(
                  controller: _nameCtrl,
                  style: fieldStyle,
                  decoration: _fieldDecoration(
                    context,
                    icon: Icons.person_outline_rounded,
                    hint: 'profile.hint_fullname'.tr(),
                    controller: _nameCtrl,
                    showCheckMark: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'profile.val_name'.tr()
                      : null,
                ),
              ),

              AppGap.h10,

              FieldCardWidget(
                child: ListTile(
                  contentPadding: AppPad.h12v4,
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppBorderRadius.a8,
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.dob'.tr(),
                        style: AppTextStyles.s10.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(formattedDate, style: AppTextStyles.s14),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                  onTap: _pickDate,
                ),
              ),

              AppGap.h24,

              EditProfileSectionHeaderWidget(
                title: 'profile.contact_info'.tr(),
              ),
              AppGap.h8,

              FieldCardWidget(
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: fieldStyle,
                  decoration: _fieldDecoration(
                    context,
                    icon: Icons.email_outlined,
                    hint: 'profile.hint_email'.tr(),
                    controller: _emailCtrl,
                    showCheckMark: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'profile.val_email1'.tr();
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'profile.val_email2'.tr();
                    }
                    return null;
                  },
                ),
              ),

              AppGap.h10,

              FieldCardWidget(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: fieldStyle,
                  decoration: _fieldDecoration(
                    context,
                    icon: Icons.phone_outlined,
                    hint: 'profile.phoneNo'.tr(),
                    controller: _phoneCtrl,
                    showCheckMark: false,
                  ),
                ),
              ),

              AppGap.h24,

              EditProfileSectionHeaderWidget(title: 'profile.about_u'.tr()),
              AppGap.h8,

              FieldCardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      maxLength: _bioMaxLength,
                      style: fieldStyle,
                      decoration: InputDecoration(
                        hintText: 'profile.hint_bio'.tr(),
                        hintStyle: AppTextStyles.s14.copyWith(
                          color: context.appColors.inputHint,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            widthFactor: 1.0,
                            heightFactor: 4.0,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppBorderRadius.a8,
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        alignLabelWithHint: true,
                        counterText: '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 8),
                      child: Text(
                        '${_bioCtrl.text.length}/$_bioMaxLength',
                        style: AppTextStyles.s10.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppGap.h32,

              // Save button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB88C), Color(0xFFFF6B35)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: AppBorderRadius.a16,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppBorderRadius.a16,
                    onTap: _save,
                    child: Center(
                      child: Text(
                        'common.save_changes'.tr(),
                        style: AppTextStyles.s16.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              AppGap.h20,

              // Danger zone
              Container(
                padding: AppPad.a16,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: AppBorderRadius.a16,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.danger_zone'.tr(),
                      style: AppTextStyles.s14.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      'profile.danger'.tr(),
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                    ),
                    AppGap.h12,
                    DangerTileWidget(
                      label: 'profile.change_pw'.tr(),
                      onTap: _showChangePassword,
                    ),
                    const Divider(height: 1, color: Color(0xFFFFCDD2)),
                    DangerTileWidget(
                      label: 'profile.delete_acc'.tr(),
                      onTap: _showDeleteAccount,
                    ),
                  ],
                ),
              ),

              AppGap.h40,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required bool showCheckMark,
  }) {
    final appColors = context.appColors;

    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.s14.copyWith(color: appColors.inputHint),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppBorderRadius.a8,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
      suffixIcon: showCheckMark
          ? ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => value.text.trim().isNotEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }
}
