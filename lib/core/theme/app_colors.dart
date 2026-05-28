import 'dart:ui';
import 'package:flutter/material.dart' show LinearGradient, Alignment;

class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFFEFE8);
  static const Color primaryDark = Color(0xFFE05521);

  static const Color lightYellowBackground = Color(0xFFFFE787);

  static const Color secondary = Color(0xFF34C759);
  static const Color secondaryLight = Color(0xFFEAF9EE);
  static const Color secondaryDark = Color(0xFF249A43);

  static const Color accent = Color(0xFFFFD60A);
  static const Color accentDark = Color(0xFFD8A500);

  // ─── Text ────────────────────────────────────────────────────────────
  static const Color textColor = Color(0xFF3C3C43);


  // ─── Gradient ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // ─── Neutrals ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7FA);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF636366);
  static const Color textHint = Color(0xFF8E8E93);

  // ─── Semantic ────────────────────────────────────────────────────────────
<<<<<<< Updated upstream
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color lightGray = Color(0xFFD3D1D1);
=======
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEAF9EE);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningLight = Color(0xFFFFF5E8);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFFECEA);
  static const Color lightGray = Color(0xFFD1D1D6);
>>>>>>> Stashed changes

  // ─── Macro colors ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFF34C759);
  static const Color carbs = Color(0xFFFFD60A);
  static const Color fat = Color(0xFFFF6B35);

  // ─── Meal type colors ────────────────────────────────────────────────────
  static const Color breakfast = Color(0xFFFF6B35);
  static const Color lunch = Color(0xFF34C759);
  static const Color dinner = Color(0xFF5856D6);
  static const Color snack = Color(0xFFFF9F0A);

  // ─── Legacy / misc ───────────────────────────────────────────────────────
  static const Color electricBlue = Color(0xFF007AFF);
  static const Color orange = Color(0xFFFD7E14);
  static const Color rustyRed = Color(0xFFFF3B30);
  static const Color gray = Color(0xFF8E8E93);
  static const Color auroMetalAaurus = Color(0xFF636366);
  static const Color raisinBlack = Color(0xFF1C1C1E);
  static const Color darkShadeOfGray = Color.fromRGBO(17, 17, 17, 0.5);
  static const Color black50 = Color(0x80000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color highlight = orange;
  static const Color active = primary;
  static const Color bodyBackground = white;
  static const Color border = Color(0xFFD1D1D6);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color sectionTitle = primary;
  static const Color text = raisinBlack;
  static const Color description = raisinBlack;
  static const Color icon = raisinBlack;
  static const Color barrier = darkShadeOfGray;
  static const Color dialogBarrier = darkShadeOfGray;
  static const Color mbsBarrier = darkShadeOfGray;

  static const Color shadowBlack15 = Color.fromRGBO(60, 60, 67, 0.18);
  static const Color formShadow = Color.fromRGBO(60, 60, 67, 0.12);

  // Form
  static const Color formTitle = primary;
  static const Color formFieldLabel = raisinBlack;
  static const Color formRequired = rustyRed;
  static const Color hintText = auroMetalAaurus;

  // Shimmer
  static const Color shimmerBaseColor = Color(0xFFEAEAEE);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F8);
}
