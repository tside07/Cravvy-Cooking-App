import 'dart:ui';
import 'package:flutter/material.dart' show LinearGradient, Alignment;

class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFFEDE6);
  static const Color primaryDark = Color(0xFFCC4D1A);

  static const Color lightYellowBackground = Color(0xFFFFE787);

  static const Color secondary = Color(0xFF2EC4B6);
  static const Color secondaryLight = Color(0xFFE0F7F5);
  static const Color secondaryDark = Color(0xFF1A9D91);

  static const Color accent = Color(0xFFFFE66D);
  static const Color accentDark = Color(0xFFF0C800);

  // ─── Text ────────────────────────────────────────────────────────────
  static const Color textColor = Color(0xFF6A8042);

  // ─── Gradient ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // ─── Neutrals ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFFFEDED);
  static const Color lightGray = Color(0xFFD3D1D1);

  // ─── Macro colors ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFF2EC4B6);
  static const Color carbs = Color(0xFFFFE66D);
  static const Color fat = Color(0xFFFF6B35);

  // ─── Meal type colors ────────────────────────────────────────────────────
  static const Color breakfast = Color(0xFFFF6B35);
  static const Color lunch = Color(0xFF2EC4B6);
  static const Color dinner = Color(0xFF7C3AED);
  static const Color snack = Color(0xFFF59E0B);

  // ─── Legacy / misc ───────────────────────────────────────────────────────
  static const Color electricBlue = Color(0xFF04589C);
  static const Color orange = Color(0xFFFD7E14);
  static const Color rustyRed = Color(0xFFDC3545);
  static const Color gray = Color(0xFF808080);
  static const Color auroMetalAaurus = Color(0xFF6C757D);
  static const Color raisinBlack = Color(0xFF202020);
  static const Color darkShadeOfGray = Color.fromRGBO(17, 17, 17, 0.5);
  static const Color black50 = Color(0x80000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color highlight = orange;
  static const Color active = primary;
  static const Color bodyBackground = white;
  static const Color border = Color(0xFFDEE2E6);
  static const Color divider = Color(0xFFE8E9EA);
  static const Color sectionTitle = primary;
  static const Color text = raisinBlack;
  static const Color description = raisinBlack;
  static const Color icon = raisinBlack;
  static const Color barrier = darkShadeOfGray;
  static const Color dialogBarrier = darkShadeOfGray;
  static const Color mbsBarrier = darkShadeOfGray;

  static const Color shadowBlack15 = Color.fromRGBO(0, 0, 0, 0.15);
  static const Color formShadow = Color.fromRGBO(76, 91, 212, 0.15);

  // Form
  static const Color formTitle = primary;
  static const Color formFieldLabel = raisinBlack;
  static const Color formRequired = rustyRed;
  static const Color hintText = auroMetalAaurus;

  // Shimmer
  static const Color shimmerBaseColor = Color(0xFFF1F2F3);
  static const Color shimmerHighlightColor = Color(0xFFE3E6E8);
}
