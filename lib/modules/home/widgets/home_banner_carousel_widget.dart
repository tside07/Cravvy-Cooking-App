import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cravvy_cooking_app/core/utils/featured_recipes_utils.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// Home hero carousel: in-app promos + featured recipes (not external articles).
class HomeBannerCarouselWidget extends StatefulWidget {
  const HomeBannerCarouselWidget({super.key});

  @override
  State<HomeBannerCarouselWidget> createState() =>
      _HomeBannerCarouselWidgetState();
}

class _HomeBannerCarouselWidgetState extends State<HomeBannerCarouselWidget> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecipeProvider>();
      if (provider.status == RecipeStatus.initial) {
        provider.loadAll();
      }
    });
  }

  List<_BannerSlide> _buildSlides(RecipeProvider provider) {
    final slides = <_BannerSlide>[
      _BannerSlide(
        titleKey: 'home.banner_promo_plan_title',
        subtitleKey: 'home.banner_promo_plan_sub',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A8A42), Color(0xFF4A6B2E)],
        ),
        emoji: '📅',
        onTap: (ctx) => ctx.read<DashboardTabProvider>().switchTo(1),
      ),
      _BannerSlide(
        titleKey: 'home.banner_promo_premium_title',
        subtitleKey: 'home.banner_promo_premium_sub',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF77C0F), Color(0xFFD97706)],
        ),
        emoji: '✨',
        onTap: (ctx) => ctx.push(AppRouter.premium),
      ),
    ];

    if (provider.isLoaded) {
      final filterKey = buildFeaturedFilterKey('all', null);
      final recipes = provider.featuredRecipes(
        filterKey: filterKey,
        mealType: 'all',
      );
      for (final recipe in recipes.take(5)) {
        slides.add(_BannerSlide.recipe(recipe));
      }
    }

    return slides;
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        final slides = _buildSlides(provider);
        final slideCount = slides.length;

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: slideCount,
                options: CarouselOptions(
                  height: 168,
                  viewportFraction: 0.88,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.18,
                  enableInfiniteScroll: slideCount > 1,
                  autoPlay: slideCount > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, _) =>
                      setState(() => _currentIndex = index),
                ),
                itemBuilder: (context, index, _) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BannerCard(slide: slide),
                  );
                },
              ),
              AppGap.h12,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slideCount, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerSlide {
  final String? titleKey;
  final String? subtitleKey;
  final String? titleText;
  final String? subtitleText;
  final String? imageUrl;
  final Gradient? gradient;
  final String? emoji;
  final void Function(BuildContext context)? onTap;
  final Recipe? recipe;

  const _BannerSlide({
    this.titleKey,
    this.subtitleKey,
    this.titleText,
    this.subtitleText,
    this.imageUrl,
    this.gradient,
    this.emoji,
    this.onTap,
    this.recipe,
  });

  factory _BannerSlide.recipe(Recipe recipe) {
    return _BannerSlide(
      titleText: recipe.name,
      subtitleText: '${recipe.calories} kcal',
      imageUrl: recipe.imageUrl,
      recipe: recipe,
      onTap: (ctx) =>
          ctx.push(AppRouter.mealDetail, extra: recipe.toMeal()),
    );
  }

  String title(BuildContext context) =>
      titleText ?? titleKey!.tr();

  String subtitle(BuildContext context) =>
      subtitleText ?? subtitleKey!.tr();
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.slide});

  final _BannerSlide slide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: slide.onTap != null ? () => slide.onTap!(context) : null,
        borderRadius: AppBorderRadius.a20,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.a20,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppBorderRadius.a20,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (slide.imageUrl != null && slide.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: slide.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        _GradientBackground(slide: slide),
                  )
                else
                  _GradientBackground(slide: slide),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: AppPad.a20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (slide.recipe != null)
                        Container(
                          padding: AppPad.h8v4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            borderRadius: AppBorderRadius.a8,
                          ),
                          child: Text(
                            'home.banner_featured_tag'.tr(),
                            style: AppTextStyles.s10.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Text(
                        slide.title(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s18.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        slide.subtitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s12.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.slide});

  final _BannerSlide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: slide.gradient ??
            LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
      ),
      alignment: Alignment.topRight,
      padding: const EdgeInsets.all(20),
      child: Text(
        slide.emoji ?? '🍳',
        style: const TextStyle(fontSize: 56),
      ),
    );
  }
}
