import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppDecorations {
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
      color: Color.fromRGBO(60, 60, 67, 0.1),
    ),
  ];

  static const thumbnailDecocation = BoxDecoration(
    color: AppColors.white,
    boxShadow: subtleShadow,
  );

  static const thumbnailShadow = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
      color: Color.fromRGBO(60, 60, 67, 0.1),
    ),
  ];
}