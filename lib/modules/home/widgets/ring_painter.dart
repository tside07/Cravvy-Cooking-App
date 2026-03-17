import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class RingPainter extends CustomPainter {
  const RingPainter({required this.progress});

  final double progress;

  static const double _strokeWidth = 14.0;
  static const double _startAngle = -1.5708; // -π/2

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      progress * 6.2832,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
