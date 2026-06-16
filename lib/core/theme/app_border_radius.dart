import 'package:flutter/material.dart';

import 'app_radius.dart';

abstract final class AppBorderRadius {
  // ─── Soft UI Evolution — unified semantic radii ──────────────────────────
  /// chip, badge, small pill.
  static const BorderRadius chip = a8;
  /// main card (standardized down from 16–24).
  static const BorderRadius card = a12;
  /// every button (CravvyButton + ElevatedButton in sync).
  static const BorderRadius button = a14;
  /// bottom sheet, large container.
  static const BorderRadius sheet = a24;

  // iOS17 baseline radii
  static const BorderRadius iosSmall = a8;
  static const BorderRadius iosField = a10;
  static const BorderRadius iosCard = a12;
  static const BorderRadius iosSection = a14;
  static const BorderRadius iosButton = a16;
  static const BorderRadius iosPill = a20;
  static const BorderRadius iosSheet = a24;

  // Backward-compatible existing constants.
  static const BorderRadius a2 = BorderRadius.all(AppRadius.c2);
  static const BorderRadius a3 = BorderRadius.all(AppRadius.c3);
  static const BorderRadius a4 = BorderRadius.all(AppRadius.c4);
  static const BorderRadius a6 = BorderRadius.all(AppRadius.c6);
  static const BorderRadius a8 = BorderRadius.all(AppRadius.c8);
  static const BorderRadius a10 = BorderRadius.all(AppRadius.c10);
  static const BorderRadius a12 = BorderRadius.all(AppRadius.c12);
  static const BorderRadius a14 = BorderRadius.all(AppRadius.c14);
  static const BorderRadius a16 = BorderRadius.all(AppRadius.c16);
  static const BorderRadius a18 = BorderRadius.all(AppRadius.c18);
  static const BorderRadius a20 = BorderRadius.all(AppRadius.c20);
  static const BorderRadius a22 = BorderRadius.all(AppRadius.c22);
  static const BorderRadius a24 = BorderRadius.all(AppRadius.c24);
  static const BorderRadius a26 = BorderRadius.all(AppRadius.c26);
  static const BorderRadius a28 = BorderRadius.all(AppRadius.c28);
  static const BorderRadius a30 = BorderRadius.all(AppRadius.c30);
  static const BorderRadius a32 = BorderRadius.all(AppRadius.c32);
  static const BorderRadius a34 = BorderRadius.all(AppRadius.c34);
  static const BorderRadius a36 = BorderRadius.all(AppRadius.c36);
  static const BorderRadius a38 = BorderRadius.all(AppRadius.c38);
  static const BorderRadius a40 = BorderRadius.all(AppRadius.c40);
  static const BorderRadius a42 = BorderRadius.all(AppRadius.c42);
  static const BorderRadius a44 = BorderRadius.all(AppRadius.c44);
  static const BorderRadius a46 = BorderRadius.all(AppRadius.c46);
  static const BorderRadius a48 = BorderRadius.all(AppRadius.c48);
  static const BorderRadius a50 = BorderRadius.all(AppRadius.c50);

  static const BorderRadius t8 = BorderRadius.vertical(top: AppRadius.c8);
  static const BorderRadius b8 = BorderRadius.vertical(bottom: AppRadius.c8);
  static const BorderRadius b10 = BorderRadius.vertical(bottom: AppRadius.c10);
}
