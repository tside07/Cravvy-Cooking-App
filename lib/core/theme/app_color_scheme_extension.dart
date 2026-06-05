import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/constants/app_color_tokens.dart';

/// Semantic app colors beyond [ColorScheme], resolved per brightness.
@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.backgroundMain,
    required this.cardSurface,
    required this.elevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textLink,
    required this.borderDivider,
    required this.iconInactive,
    required this.iconActive,
    required this.inputFieldBg,
    required this.inputBorder,
    required this.inputHint,
    required this.chipBg,
    required this.chipBorder,
    required this.toggleTrackOff,
    required this.navSelectedHighlight,
    required this.chipSelectedBg,
    required this.chipSelectedBorder,
    required this.chipSelectedText,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.onPrimary,
  });

  final Color backgroundMain;
  final Color cardSurface;
  final Color elevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textLink;
  final Color borderDivider;
  final Color iconInactive;
  final Color iconActive;
  final Color inputFieldBg;
  final Color inputBorder;
  final Color inputHint;
  final Color chipBg;
  final Color chipBorder;
  final Color toggleTrackOff;
  final Color navSelectedHighlight;
  final Color chipSelectedBg;
  final Color chipSelectedBorder;
  final Color chipSelectedText;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color onPrimary;

  static const light = AppColorExtension(
    backgroundMain: AppColorTokens.backgroundMain,
    cardSurface: AppColorTokens.cardSurface,
    elevated: AppColorTokens.elevated,
    textPrimary: AppColorTokens.textPrimary,
    textSecondary: AppColorTokens.textSecondary,
    textDisabled: AppColorTokens.textDisabled,
    textLink: AppColorTokens.textLink,
    borderDivider: AppColorTokens.borderDivider,
    iconInactive: AppColorTokens.iconInactive,
    iconActive: AppColorTokens.iconActive,
    inputFieldBg: AppColorTokens.inputFieldBg,
    inputBorder: AppColorTokens.inputBorder,
    inputHint: AppColorTokens.inputHint,
    chipBg: AppColorTokens.chipBg,
    chipBorder: AppColorTokens.chipBorder,
    toggleTrackOff: AppColorTokens.toggleTrackOff,
    navSelectedHighlight: AppColorTokens.navSelectedHighlight,
    chipSelectedBg: AppColorTokens.chipSelectedBg,
    chipSelectedBorder: AppColorTokens.chipSelectedBorder,
    chipSelectedText: AppColorTokens.chipSelectedText,
    shimmerBase: AppColorTokens.shimmerBase,
    shimmerHighlight: AppColorTokens.shimmerHighlight,
    onPrimary: AppColorTokens.onPrimary,
  );

  static const dark = AppColorExtension(
    backgroundMain: AppColorTokens.darkBackgroundMain,
    cardSurface: AppColorTokens.darkCardSurface,
    elevated: AppColorTokens.darkElevated,
    textPrimary: AppColorTokens.darkTextPrimary,
    textSecondary: AppColorTokens.darkTextSecondary,
    textDisabled: AppColorTokens.darkTextDisabled,
    textLink: AppColorTokens.darkTextLink,
    borderDivider: AppColorTokens.darkBorderDivider,
    iconInactive: AppColorTokens.darkIconInactive,
    iconActive: AppColorTokens.darkIconActive,
    inputFieldBg: AppColorTokens.darkInputFieldBg,
    inputBorder: AppColorTokens.darkInputBorder,
    inputHint: AppColorTokens.darkInputHint,
    chipBg: AppColorTokens.darkChipBg,
    chipBorder: AppColorTokens.darkChipBorder,
    toggleTrackOff: AppColorTokens.darkToggleTrackOff,
    navSelectedHighlight: AppColorTokens.darkNavSelectedHighlight,
    chipSelectedBg: AppColorTokens.darkChipSelectedBg,
    chipSelectedBorder: AppColorTokens.darkChipSelectedBorder,
    chipSelectedText: AppColorTokens.darkChipSelectedText,
    shimmerBase: AppColorTokens.darkShimmerBase,
    shimmerHighlight: AppColorTokens.darkShimmerHighlight,
    onPrimary: AppColorTokens.darkOnPrimary,
  );

  @override
  AppColorExtension copyWith({
    Color? backgroundMain,
    Color? cardSurface,
    Color? elevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textLink,
    Color? borderDivider,
    Color? iconInactive,
    Color? iconActive,
    Color? inputFieldBg,
    Color? inputBorder,
    Color? inputHint,
    Color? chipBg,
    Color? chipBorder,
    Color? toggleTrackOff,
    Color? navSelectedHighlight,
    Color? chipSelectedBg,
    Color? chipSelectedBorder,
    Color? chipSelectedText,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? onPrimary,
  }) {
    return AppColorExtension(
      backgroundMain: backgroundMain ?? this.backgroundMain,
      cardSurface: cardSurface ?? this.cardSurface,
      elevated: elevated ?? this.elevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textLink: textLink ?? this.textLink,
      borderDivider: borderDivider ?? this.borderDivider,
      iconInactive: iconInactive ?? this.iconInactive,
      iconActive: iconActive ?? this.iconActive,
      inputFieldBg: inputFieldBg ?? this.inputFieldBg,
      inputBorder: inputBorder ?? this.inputBorder,
      inputHint: inputHint ?? this.inputHint,
      chipBg: chipBg ?? this.chipBg,
      chipBorder: chipBorder ?? this.chipBorder,
      toggleTrackOff: toggleTrackOff ?? this.toggleTrackOff,
      navSelectedHighlight:
          navSelectedHighlight ?? this.navSelectedHighlight,
      chipSelectedBg: chipSelectedBg ?? this.chipSelectedBg,
      chipSelectedBorder: chipSelectedBorder ?? this.chipSelectedBorder,
      chipSelectedText: chipSelectedText ?? this.chipSelectedText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppColorExtension lerp(AppColorExtension? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      backgroundMain: Color.lerp(backgroundMain, other.backgroundMain, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      borderDivider: Color.lerp(borderDivider, other.borderDivider, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      iconActive: Color.lerp(iconActive, other.iconActive, t)!,
      inputFieldBg: Color.lerp(inputFieldBg, other.inputFieldBg, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputHint: Color.lerp(inputHint, other.inputHint, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      toggleTrackOff: Color.lerp(toggleTrackOff, other.toggleTrackOff, t)!,
      navSelectedHighlight:
          Color.lerp(navSelectedHighlight, other.navSelectedHighlight, t)!,
      chipSelectedBg: Color.lerp(chipSelectedBg, other.chipSelectedBg, t)!,
      chipSelectedBorder:
          Color.lerp(chipSelectedBorder, other.chipSelectedBorder, t)!,
      chipSelectedText:
          Color.lerp(chipSelectedText, other.chipSelectedText, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

extension AppColorContext on BuildContext {
  AppColorExtension get appColors =>
      Theme.of(this).extension<AppColorExtension>() ?? AppColorExtension.light;

  ColorScheme get colors => Theme.of(this).colorScheme;
}
