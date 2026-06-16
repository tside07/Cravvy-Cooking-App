import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

/// Semantic color tokens for light and dark themes.
/// Brand colors (primary orange, teal secondary) stay in [AppColors].
abstract final class AppColorTokens {
  // ─── Light ─────────────────────────────────────────────────────────────────
  // Soft UI Evolution: warm neutral background instead of cool gray.
  static const backgroundMain = Color(0xFFF4F3F1); // warm gray
  static const cardSurface = AppColors.surface;
  static const elevated = AppColors.surface;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textDisabled = AppColors.textHint;
  static const textLink = AppColors.primary;
  static const borderDivider = Color(0xFFEAE7E3); // warm divider
  static const iconInactive = AppColors.textHint;
  static const iconActive = AppColors.primary;
  static const inputFieldBg = AppColors.surface;
  static const inputBorder = borderDivider;
  static const inputHint = AppColors.textHint;
  static const chipBg = AppColors.surface;
  static const chipBorder = borderDivider;
  static const toggleTrackOff = AppColors.lightGray;
  static const navSelectedHighlight = AppColors.primaryLight;
  static const chipSelectedBg = AppColors.primaryLight;
  static const chipSelectedBorder = AppColors.primary;
  static const chipSelectedText = AppColors.primaryDark;
  static const shimmerBase = AppColors.shimmerBaseColor;
  static const shimmerHighlight = AppColors.shimmerHighlightColor;
  static const onPrimary = AppColors.white;

  // ─── Dark (spec) ─────────────────────────────────────────────────────────
  // Soft UI Evolution: warm dark neutrals instead of cool blue-gray.
  static const darkBackgroundMain = Color(0xFF1B1714); // warm dark
  static const darkCardSurface = Color(0xFF272320);
  static const darkElevated = Color(0xFF2F2A26);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  // Raised from #8F959E for AA contrast on warm dark surfaces.
  static const darkTextSecondary = Color(0xFFC2C6CC);
  // Disabled text is WCAG-exempt from contrast, but nudged up for readability.
  static const darkTextDisabled = Color(0xFF837C75);
  static const darkTextLink = AppColors.primary;
  static const darkBorderDivider = Color(0xFF37322D);
  static const darkIconInactive = Color(0xFFC2C6CC);
  static const darkIconActive = AppColors.primary;
  static const darkInputFieldBg = Color(0xFF272320);
  static const darkInputBorder = Color(0xFF37322D);
  static const darkInputHint = Color(0xFF9A938C); // AA on dark input bg
  static const darkChipBg = Color(0xFF272320);
  static const darkChipBorder = Color(0xFF37322D);
  static const darkToggleTrackOff = Color(0xFF4A443E);
  static const darkNavSelectedHighlight = Color(0x33FF6B35);
  static const darkChipSelectedBg = Color(0xFF3A322C);
  static const darkChipSelectedBorder = AppColors.primary;
  static const darkChipSelectedText = AppColors.primary;
  static const darkShimmerBase = Color(0xFF272320);
  static const darkShimmerHighlight = Color(0xFF332E2A);
  static const darkOnPrimary = Color(0xFFFFFFFF);
}
