import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/theme/app_text_styles.dart';
import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';

abstract final class AppInputDecoration {
  static const Color _idleLine = Color(0xFF9E9E9E);
  static const Color _focusLine = Color(0xFFFFFFFF);

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
