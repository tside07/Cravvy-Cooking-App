import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/constants/app_constants.dart';

/// Vellum-flavoured type + shape helpers scoped to the chat screen.
///
/// The app ships only Inter + Baloo2, so Vellum's serif/grotesk/mono trio is
/// mapped onto them: Baloo2 for the editorial [display] role (assistant names,
/// headings), Inter for body, and an uppercase letter-spaced Inter treatment
/// ([monoCaps]) plus a tabular-figure variant ([monoMeta]) for the "machine
/// voice" — status, timestamps, and eyebrow labels.
abstract final class ChatStyle {
  // Gentle radii: 14 for cards/bubbles, 10 for controls.
  static const double cardRadius = 14;
  static const double controlRadius = 10;
  static const double bubbleRadius = 16;
  static const double tailRadius = 4;

  // Quick ease-out entrances, no bounce (spec §1).
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 220);

  /// Editorial display face — assistant names, headings.
  static TextStyle display(
    Color color, {
    double size = 17,
    FontWeight weight = FontWeight.w600,
  }) =>
      TextStyle(
        fontFamily: AppConst.headingFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.15,
      );

  /// ALL-CAPS eyebrow / status label (the only caps allowed by the copy rules).
  static TextStyle monoCaps(
    Color color, {
    double size = 10.5,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontFamily: AppConst.interFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 1.3,
        height: 1.2,
      );

  /// "Machine" meta — timestamps, token/stat lines. Tabular figures + slight
  /// tracking evoke monospace without a bundled mono face.
  static TextStyle monoMeta(
    Color color, {
    double size = 11,
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(
        fontFamily: AppConst.interFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.2,
        height: 1.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─── Time helpers ──────────────────────────────────────────────────────────

  /// 24h clock, e.g. `14:32`.
  static String timeOfDay(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Compact relative label for recent-chat rows, e.g. `now`, `2m`, `3h`, `5d`.
  static String relativeShort(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 365) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 365).floor()}y';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
