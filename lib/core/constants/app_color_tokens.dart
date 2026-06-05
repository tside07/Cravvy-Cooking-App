import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

/// Semantic color tokens for light and dark themes.
/// Brand colors (primary orange, teal secondary) stay in [AppColors].
abstract final class AppColorTokens {
  // ─── Light ─────────────────────────────────────────────────────────────────
  static const backgroundMain = AppColors.background;
  static const cardSurface = AppColors.surface;
  static const elevated = AppColors.surface;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textDisabled = AppColors.textHint;
  static const textLink = AppColors.primary;
  static const borderDivider = AppColors.border;
  static const iconInactive = AppColors.textHint;
  static const iconActive = AppColors.primary;
  static const inputFieldBg = AppColors.surface;
  static const inputBorder = AppColors.border;
  static const inputHint = AppColors.textHint;
  static const chipBg = AppColors.surface;
  static const chipBorder = AppColors.border;
  static const toggleTrackOff = AppColors.lightGray;
  static const navSelectedHighlight = AppColors.primaryLight;
  static const chipSelectedBg = AppColors.primaryLight;
  static const chipSelectedBorder = AppColors.primary;
  static const chipSelectedText = AppColors.primaryDark;
  static const shimmerBase = AppColors.shimmerBaseColor;
  static const shimmerHighlight = AppColors.shimmerHighlightColor;
  static const onPrimary = AppColors.white;

  // ─── Dark (spec) ─────────────────────────────────────────────────────────
  static const darkBackgroundMain = Color(0xFF1B262C);
  static const darkCardSurface = Color(0xFF243039);
  static const darkElevated = Color(0xFF2C3E47);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8F959E);
  static const darkTextDisabled = Color(0xFF555C63);
  static const darkTextLink = AppColors.primary;
  static const darkBorderDivider = Color(0xFF2C3E47);
  static const darkIconInactive = Color(0xFF8F959E);
  static const darkIconActive = AppColors.primary;
  static const darkInputFieldBg = Color(0xFF243039);
  static const darkInputBorder = Color(0xFF2C3E47);
  static const darkInputHint = Color(0xFF8F959E);
  static const darkChipBg = Color(0xFF243039);
  static const darkChipBorder = Color(0xFF2C3E47);
  static const darkToggleTrackOff = Color(0xFF555C63);
  static const darkNavSelectedHighlight = Color(0x33FF6B35);
  static const darkChipSelectedBg = Color(0xFF2C3E47);
  static const darkChipSelectedBorder = AppColors.primary;
  static const darkChipSelectedText = AppColors.primary;
  static const darkShimmerBase = Color(0xFF243039);
  static const darkShimmerHighlight = Color(0xFF2C3E47);
  static const darkOnPrimary = Color(0xFFFFFFFF);
}
