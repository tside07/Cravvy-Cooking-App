import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

/// Shared [InputDecoration]s for the project.
///
/// Use with a plain [TextField]/[TextFormField] and `.copyWith(...)` to set
/// per-field bits (labelText, hintText, suffixIcon, styles), e.g.:
/// ```dart
/// TextField(
///   decoration: AppInputDecoration.underline.copyWith(
///     labelText: 'Username',
///     suffixIcon: isValid ? const Icon(Icons.check) : null,
///   ),
/// )
/// ```
abstract final class AppInputDecoration {
  static const Color _idleLine = Color(0xFF9E9E9E);
  static const Color _focusLine = Color(0xFF34C358);

  /// Minimal underline field: grey line when idle, green when focused.
  /// Floating label stays above the value (matches the Sign Up mock).
  static final InputDecoration underline = InputDecoration(
    isDense: false,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
