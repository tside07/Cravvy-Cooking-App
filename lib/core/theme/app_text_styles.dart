import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // ─── Heading / display (Baloo 2) ─────────────────────────────────────────
  // Rounded display font for screen titles and large figures
  // (calorie counts, "Hôm nay ăn gì?"). Body stays Inter.

  /// Largest figure / hero number (e.g. calorie total).
  static const TextStyle display = TextStyle(
    fontFamily: AppConst.headingFont,
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  /// Screen title.
  static const TextStyle h1 = TextStyle(
    fontFamily: AppConst.headingFont,
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Section heading.
  static const TextStyle h2 = TextStyle(
    fontFamily: AppConst.headingFont,
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle s10 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static const TextStyle s11 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static const TextStyle s12 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );
  static const TextStyle s13 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
  static const TextStyle s14 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle s15 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle s16 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle s17 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.38,
  );
  static const TextStyle s18 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static const TextStyle s20 = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // Compatibility aliases for safe migration.
  static const TextStyle caption = s12;
  static const TextStyle body = s14;
  static const TextStyle subtitle = s16;
  static const TextStyle title = s18;

  static const TextStyle appbarTitle = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Button

  static const TextStyle button = TextStyle(
    fontFamily: AppConst.interFont,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle smallButton = TextStyle(
    fontFamily: AppConst.interFont,
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textButton = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Input / Form

  static const TextStyle inputTitle = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.formTitle,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle inputFieldLabel = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.formFieldLabel,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle inputHintText = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.hintText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle inputError = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.error,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  // Text

  static const TextStyle text = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textMedium = TextStyle(
    fontFamily: AppConst.interFont,
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  //

  static const TextStyle cupertinoActionSheetAction = TextStyle(
    fontFamily: AppConst.interFont,
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle tabBarLabel = TextStyle(
    fontFamily: AppConst.interFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bottomSheetTitle = TextStyle(
    fontFamily: AppConst.interFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  // Intro

  static const TextStyle introDescription = text;
}
