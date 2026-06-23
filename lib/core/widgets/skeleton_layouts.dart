import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/core/widgets/skeleton.dart';

/// Reusable skeleton layouts shaped after the app's real cards, so a loading
/// view has the same footprint as the content that replaces it (no layout
/// shift). Each renders static [BuildContext.cardBox] chrome and shimmers only
/// the gray placeholder shapes inside via [Skeleton].

/// Vertical media card — mirrors [RecipeCardWidget] (featured) and the home
/// "today meals" scroll card. Tune [width] / [imageHeight] per use.
class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({
    super.key,
    this.width = 180,
    this.imageHeight = 150,
    this.margin = const EdgeInsets.only(right: 12),
  });

  final double width;
  final double imageHeight;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      decoration: context.cardBox(radius: 16),
      clipBehavior: Clip.hardEdge,
      child: Skeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: imageHeight, radius: 0),
            Padding(
              padding: AppPad.a10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(widthFactor: 0.92, height: 11),
                  AppGap.h6,
                  const SkeletonLine(widthFactor: 0.6, height: 11),
                  AppGap.h10,
                  Row(
                    children: const [
                      SkeletonBox(width: 46, height: 10, radius: 4),
                      Spacer(),
                      SkeletonBox(width: 32, height: 10, radius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width meal row — mirrors [MealCardWidget] (image + label/title/macros +
/// trailing action column).
class MealRowCardSkeleton extends StatelessWidget {
  const MealRowCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPad.b12,
      child: Container(
        decoration: context.cardBox(radius: 12),
        clipBehavior: Clip.hardEdge,
        child: Skeleton(
          child: Row(
            children: [
              const SkeletonBox(width: 90, height: 90, radius: 0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkeletonLine(widthFactor: 0.32, height: 9),
                      AppGap.h8,
                      const SkeletonLine(widthFactor: 0.8, height: 12),
                      AppGap.h8,
                      Row(
                        children: const [
                          SkeletonBox(width: 44, height: 9, radius: 4),
                          SizedBox(width: 10),
                          SkeletonBox(width: 36, height: 9, radius: 4),
                        ],
                      ),
                      AppGap.h8,
                      Row(
                        children: const [
                          SkeletonBox(width: 40, height: 16, radius: 8),
                          SizedBox(width: 4),
                          SkeletonBox(width: 40, height: 16, radius: 8),
                          SizedBox(width: 4),
                          SkeletonBox(width: 40, height: 16, radius: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonCircle(size: 32),
                    SizedBox(height: 10),
                    SkeletonCircle(size: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact list row — mirrors [RecipeSearchResultTile] (small image + title +
/// meta + trailing chevron).
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key, this.imageSize = 80});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPad.b10,
      child: Container(
        decoration: context.cardBox(radius: 16),
        clipBehavior: Clip.hardEdge,
        child: Skeleton(
          child: Row(
            children: [
              SkeletonBox(width: imageSize, height: imageSize, radius: 0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkeletonLine(widthFactor: 0.75, height: 12),
                      AppGap.h8,
                      Row(
                        children: const [
                          SkeletonBox(width: 44, height: 9, radius: 4),
                          SizedBox(width: 8),
                          SkeletonBox(width: 38, height: 9, radius: 4),
                        ],
                      ),
                      AppGap.h8,
                      Row(
                        children: const [
                          SkeletonBox(width: 36, height: 14, radius: 6),
                          SizedBox(width: 4),
                          SkeletonBox(width: 36, height: 14, radius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonCircle(size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat tile — mirrors [StatCardWidget] (icon + value + label). Pair three in a
/// [Row] to match the progress stat row.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 88,
        padding: AppPad.h10v14,
        decoration: context.cardBox(radius: 16),
        child: Skeleton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SkeletonCircle(size: 24),
              AppGap.h8,
              const SkeletonBox(width: 30, height: 18, radius: 6),
              AppGap.h6,
              const SkeletonBox(width: 48, height: 8, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Week day-strip — mirrors [WeekStripWidget] (seven equal day cells).
class WeekStripSkeleton extends StatelessWidget {
  const WeekStripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Skeleton(
        child: Row(
          children: List.generate(
            7,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: SkeletonBox(
                  width: double.infinity,
                  height: 64,
                  radius: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
