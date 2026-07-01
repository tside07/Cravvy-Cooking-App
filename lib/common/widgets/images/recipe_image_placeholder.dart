import 'package:flutter/material.dart';

/// Placeholder ảnh món ăn khi chưa có ảnh thật.
///
/// Thay ô màu phẳng + 1 icon bằng: gradient theo màu bữa ăn, một icon lớn rất mờ
/// làm hoạ tiết nền, một đĩa tròn chứa icon ở giữa, và (tuỳ chọn) tên món — để
/// các món chưa có ảnh trông có chủ đích thay vì "trống". Tự co theo kích thước.
class RecipeImagePlaceholder extends StatelessWidget {
  const RecipeImagePlaceholder({
    super.key,
    required this.icon,
    required this.color,
    required this.lightColor,
    this.name,
    this.compact = false,
  });

  /// Icon đại diện bữa ăn (breakfast/lunch/dinner/snack).
  final IconData icon;

  /// Màu nhấn của bữa ăn (dùng cho icon + tên).
  final Color color;

  /// Màu nền nhạt của bữa ăn (chân gradient).
  final Color lightColor;

  /// Tên món — hiện khi đủ chỗ và không ở chế độ [compact].
  final String? name;

  /// Thu nhỏ cho thumbnail nhỏ (chỉ icon, không tên).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightColor,
            Color.alphaBlend(color.withValues(alpha: 0.18), lightColor),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight.isFinite ? c.maxHeight : 120.0;
          final w = c.maxWidth.isFinite ? c.maxWidth : 120.0;
          final showName =
              !compact && (name?.trim().isNotEmpty ?? false) && h >= 96;
          final double disc =
              compact ? 40.0 : (h * 0.32).clamp(44.0, 76.0).toDouble();
          final double watermark = (h * 0.95).clamp(70.0, 220.0).toDouble();

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hoạ tiết nền: icon lớn rất mờ, lệch về góc dưới-phải.
                Positioned(
                  right: -w * 0.16,
                  bottom: -h * 0.20,
                  child: Icon(
                    icon,
                    size: watermark,
                    color: color.withValues(alpha: 0.10),
                  ),
                ),
                // Trung tâm: đĩa tròn + icon, kèm tên món nếu đủ chỗ.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: disc,
                        height: disc,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: disc * 0.55, color: color),
                      ),
                      if (showName) ...[
                        const SizedBox(height: 10),
                        Text(
                          name!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
