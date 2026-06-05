import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_border_radius.dart';
import 'package:cravvy_cooking_app/core/theme/app_color_scheme_extension.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:cravvy_cooking_app/core/theme/app_pad.dart';

/// Shared [InputDecoration] — single bordered field (no outer card wrapper).
abstract final class AppInputDecoration {
  static const double _radius = 14;

  static InputDecoration outlined(
    BuildContext context, {
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final colors = context.appColors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: colors.inputBorder),
    );

    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colors.inputFieldBg,
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: colors.inputHint, fontSize: 14, fontFamily: 'Inter'),
      labelStyle: TextStyle(color: colors.textSecondary, fontSize: 12, fontFamily: 'Inter'),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  static Widget prefixIconBox(BuildContext context, IconData icon) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colors.chipBg,
          borderRadius: AppBorderRadius.a8,
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
