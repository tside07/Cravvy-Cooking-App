import 'package:cravvy_cooking_app/init.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading primitives.
///
/// Usage: wrap a layout of [SkeletonBox] / [SkeletonLine] / [SkeletonCircle]
/// shapes in a single [Skeleton]. That applies ONE synchronized shimmer sweep
/// across every shape in the subtree (theme-aware via
/// [AppColorExtension.shimmerBase] / [shimmerHighlight]) instead of each shape
/// animating on its own.
///
/// The shapes are opaque [shimmerBase] fills; the [Skeleton]'s shader mask only
/// paints the gradient over those opaque pixels, so any surrounding card chrome
/// (a static [BuildContext.cardBox] ancestor) shows through the gaps and stays
/// still while the placeholders shimmer.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// When false, renders [child] without the shimmer animation. Useful for
  /// golden tests / reduced-motion fallbacks.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final colors = context.appColors;
    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      period: const Duration(milliseconds: 1100),
      child: child,
    );
  }
}

/// A solid rounded rectangle placeholder. Sized by [width]/[height]; a null
/// dimension takes the space the parent gives it.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A text-line placeholder with pill-rounded ends.
///
/// Pass an explicit [width], or omit it and set [widthFactor] (0–1) to size the
/// line as a fraction of the available width — the factor form must live where
/// width is bounded (a [Column], or an [Expanded] inside a [Row]).
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.widthFactor = 1,
    this.width,
    this.height = 12,
  });

  final double widthFactor;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
    if (width != null) return line;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor.clamp(0.0, 1.0),
      child: line,
    );
  }
}

/// A circular placeholder (avatar / icon badge).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}
