import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cravvy_cooking_app/core/constants/app_color_tokens.dart';
import 'package:cravvy_cooking_app/core/theme/app_color_scheme_extension.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        appColors: AppColorExtension.light,
        colorScheme: _lightColorScheme,
        statusBarIconBrightness: Brightness.dark,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        appColors: AppColorExtension.dark,
        colorScheme: _darkColorScheme,
        statusBarIconBrightness: Brightness.light,
      );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColorTokens.backgroundMain,
    onSurface: AppColorTokens.textPrimary,
    onSurfaceVariant: AppColorTokens.textSecondary,
    outline: AppColorTokens.borderDivider,
    outlineVariant: AppColors.divider,
    shadow: AppColors.shadowBlack15,
    scrim: AppColors.barrier,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.primaryLight,
    surfaceTint: AppColors.primary,
    surfaceContainerHighest: AppColorTokens.cardSurface,
    surfaceContainerHigh: AppColorTokens.elevated,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColorTokens.darkOnPrimary,
    primaryContainer: AppColorTokens.darkChipSelectedBg,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColorTokens.darkElevated,
    onSecondaryContainer: AppColorTokens.darkTextSecondary,
    tertiary: AppColors.accent,
    onTertiary: AppColorTokens.darkTextPrimary,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColorTokens.darkBackgroundMain,
    onSurface: AppColorTokens.darkTextPrimary,
    onSurfaceVariant: AppColorTokens.darkTextSecondary,
    outline: AppColorTokens.darkBorderDivider,
    outlineVariant: AppColorTokens.darkBorderDivider,
    shadow: Color(0x66000000),
    scrim: AppColors.black50,
    inverseSurface: AppColorTokens.darkTextPrimary,
    onInverseSurface: AppColorTokens.darkBackgroundMain,
    inversePrimary: AppColors.primaryDark,
    surfaceTint: AppColors.primary,
    surfaceContainerHighest: AppColorTokens.darkCardSurface,
    surfaceContainerHigh: AppColorTokens.darkElevated,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorExtension appColors,
    required ColorScheme colorScheme,
    required Brightness statusBarIconBrightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appColors.backgroundMain,
      fontFamily: 'Inter',
      extensions: [appColors],

      appBarTheme: AppBarTheme(
        backgroundColor: appColors.backgroundMain,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarIconBrightness,
        ),
        iconTheme: IconThemeData(color: appColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: appColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: appColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: appColors.textDisabled,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appColors.onPrimary,
          letterSpacing: 0.1,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: appColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark
              ? AppColorTokens.darkChipSelectedBg
              : AppColors.secondaryLight,
          foregroundColor:
              isDark ? AppColorTokens.darkTextPrimary : AppColors.secondaryDark,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
        selectionHandleColor: AppColors.primary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.inputFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          color: appColors.inputHint,
          fontSize: 15,
          fontFamily: 'Inter',
        ),
        labelStyle: TextStyle(
          color: appColors.textSecondary,
          fontSize: 15,
          fontFamily: 'Inter',
        ),
      ),

      dividerTheme: DividerThemeData(
        color: appColors.borderDivider,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: appColors.chipBg,
        disabledColor: appColors.textDisabled,
        selectedColor: appColors.chipSelectedBg,
        secondarySelectedColor: appColors.chipSelectedBg,
        labelStyle: TextStyle(
          color: appColors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: appColors.chipSelectedText,
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: appColors.chipBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: appColors.backgroundMain,
        indicatorColor: appColors.navSelectedHighlight,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: appColors.iconActive);
          }
          return IconThemeData(color: appColors.iconInactive);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? appColors.iconActive
              : appColors.iconInactive;
          return TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: color,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appColors.backgroundMain,
        selectedItemColor: appColors.iconActive,
        unselectedItemColor: appColors.iconInactive,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: appColors.backgroundMain,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: appColors.elevated,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: appColors.textSecondary,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: appColors.elevated,
        modalBackgroundColor: appColors.elevated,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.onPrimary;
          }
          return isDark ? AppColorTokens.darkTextSecondary : AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return appColors.toggleTrackOff;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      iconTheme: IconThemeData(color: appColors.iconInactive),

      cardTheme: CardThemeData(
        color: appColors.cardSurface,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : AppColors.shadowBlack15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: appColors.borderDivider)
              : BorderSide.none,
        ),
      ),
    );
  }
}
