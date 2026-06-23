import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_border_radius.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/theme/app_text_styles.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';

abstract final class AppInputDecoration {
  static const Color _idleLine = Color(0xFF9E9E9E);
  static const Color _focusLine = Color(0xFFFFFFFF);

  /// Soft UI filled card field for the dark pre-auth shell: rounded, hairline
  /// highlight at rest, warm accent ring on focus. Shared by the auth forms so
  /// every input on the dark shell reads the same.
  static InputDecoration preAuthSoft({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: AppBorderRadius.a14,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.s16.copyWith(color: PreAuthTheme.textSecondary),
      filled: true,
      fillColor: PreAuthTheme.surface,
      errorStyle: AppTextStyles.s12.copyWith(color: AppColors.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: border(PreAuthTheme.fieldBorder, 1),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.error.withValues(alpha: 0.6), 1),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  static final InputDecoration underline = InputDecoration(
    isDense: false,
    filled: false,
    fillColor: Colors.transparent,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
    labelStyle: AppTextStyles.s16.copyWith(color: PreAuthTheme.textSecondary),
    floatingLabelStyle: AppTextStyles.s13.copyWith(
      color: PreAuthTheme.textSecondary,
    ),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: _idleLine, width: 0.8),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: _idleLine, width: 0.8),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: _focusLine, width: 1.4),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.error, width: 0.8),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.error, width: 1.4),
    ),
  );

  /// Filled, rounded box with no visible border until focused.
  static final InputDecoration outline = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _focusLine, width: 1.5),
    ),
  );
}
