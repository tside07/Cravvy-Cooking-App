import 'package:flutter/material.dart';

/// Soft, low-opacity, multi-layer elevation for the "Soft UI Evolution" style.
///
/// Light mode uses two stacked soft shadows for gentle depth. Dark mode relies
/// less on shadow (a soft glow plus a 1px top highlight border conveys lift),
/// so the lists below are softer there.
///
/// Performance note: opacities are intentionally low and the layers are `const`
/// so they allocate once. Pair card lifts with `transform`/`opacity` animations
/// only — never animate width/height.
abstract final class AppShadows {
  // ─── Light ─────────────────────────────────────────────────────────────────

  /// Resting card.
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0A000000), // rgba(0,0,0,.04)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,.05)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised / featured / pressed-lift.
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,.05)
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x12000000), // rgba(0,0,0,.07)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Sheet / dialog.
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,.08)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,.10)
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  // ─── Dark ───────────────────────────────────────────────────────────────────

  /// Resting card (dark): softer single soft shadow.
  static const List<BoxShadow> e1Dark = [
    BoxShadow(
      color: Color(0x40000000), // rgba(0,0,0,.25)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised / featured (dark).
  static const List<BoxShadow> e2Dark = [
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,.30)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Sheet / dialog (dark).
  static const List<BoxShadow> e3Dark = [
    BoxShadow(
      color: Color(0x66000000), // rgba(0,0,0,.40)
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  /// Brightness-aware resting card shadow.
  static List<BoxShadow> e1Of(Brightness b) =>
      b == Brightness.dark ? e1Dark : e1;

  /// Brightness-aware raised shadow.
  static List<BoxShadow> e2Of(Brightness b) =>
      b == Brightness.dark ? e2Dark : e2;

  /// Brightness-aware sheet/dialog shadow.
  static List<BoxShadow> e3Of(Brightness b) =>
      b == Brightness.dark ? e3Dark : e3;
}
