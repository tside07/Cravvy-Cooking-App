import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:easy_localization/easy_localization.dart';

/// Hero image section with back/bookmark buttons, title, rating, and tags.
class MealDetailHeaderWidget extends StatelessWidget {
  const MealDetailHeaderWidget({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // ── Hero image ────────────────────────────────────────────────────
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Image.network(
              meal.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: meal.type.lightColor,
                child: Center(
                  child: Text(
                    meal.type.emoji,
                    style: AppTextStyles.s20.copyWith(fontSize: 64),
                  ),
                ),
              ),
            ),
          ),

          // ── Gradient overlay ──────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.70),
                  ],
                ),
              ),
            ),
          ),

          // ── Back button ───────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => context.pop(),
            ),
          ),

          // ── Bookmark button ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _CircleIconButton(
              icon: Icons.bookmark_border_rounded,
              onTap: () {},
            ),
          ),

          // ── Title / rating / tags ─────────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.s20.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                AppGap.h6,
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 18,
                    ),
                    AppGap.w4,
                    Text(
                      '4.8',
                      style: AppTextStyles.s14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppGap.w4,
                    Text(
                      'meal_detail.reviews'.tr(namedArgs: {'n': '128'}),
                      style: AppTextStyles.s12.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                AppGap.h10,
                Wrap(
                  spacing: 8,
                  children: meal.tags
                      .map(
                        (tag) => Container(
                          padding: AppPad.h10v4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: AppBorderRadius.a20,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.s12.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
