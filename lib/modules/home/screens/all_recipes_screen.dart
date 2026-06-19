import 'package:cravvy_cooking_app/core/routes/all_recipes_args.dart';

import 'package:cravvy_cooking_app/data/models/recipe.dart';

import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';

import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/modules/home/widgets/recipe_card_widget.dart';

import 'package:easy_localization/easy_localization.dart';



enum _RecipeSort {

  recommended,

  caloriesLow,

  caloriesHigh,

  prepTimeLow,

  nameAz,

}



class _TagOption {

  const _TagOption(this.value, this.labelKey);

  final String value;

  final String labelKey;

}



class AllRecipesScreen extends StatefulWidget {

  const AllRecipesScreen({super.key, required this.args});



  final AllRecipesArgs args;



  @override

  State<AllRecipesScreen> createState() => _AllRecipesScreenState();

}



class _AllRecipesScreenState extends State<AllRecipesScreen> {

  late String _mealType;

  String? _selectedTag;

  _RecipeSort _sort = _RecipeSort.recommended;

  final _searchCtrl = TextEditingController();



  static const _typeTabs = [

    ('all', 'home.tab_all', '🍽️'),

    ('breakfast', 'home.tab_breakfast', '🌅'),

    ('lunch', 'home.tab_lunch', '☀️'),

    ('dinner', 'home.tab_dinner', '🌙'),

    ('snack', 'home.tab_snack', '🍎'),

  ];



  static const _tagOptions = [

    _TagOption('High Protein', 'home.tag_high_protein'),

    _TagOption('Quick', 'home.tag_quick'),

    _TagOption('Vegan', 'home.tag_vegan'),

    _TagOption('Low Carb', 'home.tag_low_carb'),

    _TagOption('Gluten-Free', 'home.tag_gluten_free'),

    _TagOption('Meal Prep', 'home.tag_meal_prep'),

  ];



  @override

  void initState() {

    super.initState();

    _mealType = _validMealType(widget.args.initialMealType);

    if (widget.args.initialSearchQuery != null) {

      _searchCtrl.text = widget.args.initialSearchQuery!;

    }

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final provider = context.read<RecipeProvider>();

      if (!provider.isLoaded && !provider.isLoading) {

        provider.loadAll();

      }

    });

  }



  @override

  void dispose() {

    _searchCtrl.dispose();

    super.dispose();

  }



  String _validMealType(String type) {

    const allowed = {'all', 'breakfast', 'lunch', 'dinner', 'snack'};

    return allowed.contains(type) ? type : 'all';

  }



  bool get _hasActiveFilters => _mealType != 'all' || _selectedTag != null;



  List<Recipe> _filteredRecipes(List<Recipe> all) {

    var list = all;

    if (_mealType != 'all') {

      list = list.where((r) => r.mealType == _mealType).toList(growable: false);

    }

    if (_selectedTag != null) {

      final tag = _selectedTag!.toLowerCase();

      list = list

          .where((r) => r.tags.any((t) => t.toLowerCase().contains(tag)))

          .toList(growable: false);

    }

    final q = _searchCtrl.text.trim().toLowerCase();

    if (q.isNotEmpty) {

      list = list.where((r) {

        return r.name.toLowerCase().contains(q) ||

            r.tags.any((t) => t.toLowerCase().contains(q)) ||

            (r.description?.toLowerCase().contains(q) ?? false);

      }).toList(growable: false);

    }

    return _sorted(list);

  }



  List<Recipe> _sorted(List<Recipe> list) {

    final copy = List<Recipe>.from(list);

    switch (_sort) {

      case _RecipeSort.caloriesLow:

        copy.sort((a, b) => a.calories.compareTo(b.calories));

      case _RecipeSort.caloriesHigh:

        copy.sort((a, b) => b.calories.compareTo(a.calories));

      case _RecipeSort.prepTimeLow:

        copy.sort((a, b) => a.prepTime.compareTo(b.prepTime));

      case _RecipeSort.nameAz:

        copy.sort((a, b) => a.name.compareTo(b.name));

      case _RecipeSort.recommended:

        break;

    }

    return copy;

  }



  String _sortLabel(_RecipeSort sort) {

    switch (sort) {

      case _RecipeSort.recommended:

        return 'home.sort_default'.tr();

      case _RecipeSort.caloriesLow:

        return 'home.sort_calories_low'.tr();

      case _RecipeSort.caloriesHigh:

        return 'home.sort_calories_high'.tr();

      case _RecipeSort.prepTimeLow:

        return 'home.sort_time_low'.tr();

      case _RecipeSort.nameAz:

        return 'home.sort_name'.tr();

    }

  }



  Future<void> _openFilterSheet() async {

    var draftMealType = _mealType;

    String? draftTag = _selectedTag;



    final applied = await showModalBottomSheet<bool>(

      context: context,

      isScrollControlled: true,

      backgroundColor: context.appColors.cardSurface,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),

      ),

      builder: (ctx) {

        return StatefulBuilder(

          builder: (ctx, setSheetState) {

            return Padding(

              padding: EdgeInsets.only(

                left: 20,

                right: 20,

                top: 12,

                bottom: MediaQuery.paddingOf(ctx).bottom + 20,

              ),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Center(

                    child: Container(

                      width: 40,

                      height: 4,

                      decoration: BoxDecoration(

                        color: AppColors.border,

                        borderRadius: BorderRadius.circular(2),

                      ),

                    ),

                  ),

                  AppGap.h16,

                  Text(

                    'search.filter.title'.tr(),

                    style: Theme.of(ctx).textTheme.titleLarge,

                  ),

                  AppGap.h8,

                  Text(

                    'search.filter.meal_type'.tr(),

                    style: AppTextStyles.s14.copyWith(

                      fontWeight: FontWeight.w600,

                      color: context.appColors.textSecondary,

                    ),

                  ),

                  AppGap.h10,

                  Wrap(

                    spacing: 8,

                    runSpacing: 8,

                    children: _typeTabs.map((tab) {

                      final (type, labelKey, emoji) = tab;

                      final selected = draftMealType == type;

                      return FilterChip(

                        label: Text('$emoji ${labelKey.tr()}'),

                        selected: selected,

                        onSelected: (_) =>

                            setSheetState(() => draftMealType = type),

                        selectedColor: AppColors.primaryLight,

                        checkmarkColor: AppColors.primary,

                      );

                    }).toList(),

                  ),

                  AppGap.h16,

                  Text(

                    'home.filter_tags'.tr(),

                    style: AppTextStyles.s14.copyWith(

                      fontWeight: FontWeight.w600,

                      color: context.appColors.textSecondary,

                    ),

                  ),

                  AppGap.h10,

                  Wrap(

                    spacing: 8,

                    runSpacing: 8,

                    children: _tagOptions.map((opt) {

                      final selected = draftTag == opt.value;

                      return FilterChip(

                        label: Text(opt.labelKey.tr()),

                        selected: selected,

                        onSelected: (_) => setSheetState(

                          () => draftTag = selected ? null : opt.value,

                        ),

                        selectedColor: AppColors.primaryLight,

                        checkmarkColor: AppColors.primary,

                      );

                    }).toList(),

                  ),

                  AppGap.h20,

                  Row(

                    children: [

                      Expanded(

                        child: OutlinedButton(

                          onPressed: () => setSheetState(() {

                            draftMealType = 'all';

                            draftTag = null;

                          }),

                          child: Text('home.filter_reset'.tr()),

                        ),

                      ),

                      AppGap.w12,

                      Expanded(

                        child: ElevatedButton(

                          onPressed: () => Navigator.pop(ctx, true),

                          style: ElevatedButton.styleFrom(

                            backgroundColor: AppColors.primary,

                            foregroundColor: Colors.white,

                          ),

                          child: Text('home.filter_apply'.tr()),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            );

          },

        );

      },

    );

    if (applied == true && mounted) {
      setState(() {
        _mealType = draftMealType;
        _selectedTag = draftTag;
      });
    }
  }



  Future<void> _openSortSheet() async {

    final picked = await showModalBottomSheet<_RecipeSort>(

      context: context,

      backgroundColor: context.appColors.cardSurface,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),

      ),

      builder: (ctx) {

        return Padding(

          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 12),

                child: Align(

                  alignment: Alignment.centerLeft,

                  child: Text(

                    'home.sort_title'.tr(),

                    style: Theme.of(ctx).textTheme.titleLarge,

                  ),

                ),

              ),

              ..._RecipeSort.values.map(

                (option) => ListTile(

                  title: Text(_sortLabel(option)),

                  trailing: _sort == option

                      ? const Icon(Icons.check_rounded, color: AppColors.primary)

                      : null,

                  onTap: () => Navigator.pop(ctx, option),

                ),

              ),

            ],

          ),

        );

      },

    );

    if (picked != null && mounted) {

      setState(() => _sort = picked);

    }

  }



  @override

  Widget build(BuildContext context) {

    final _ = context.locale;



    return Scaffold(

      appBar: AppBar(

        title: Text('home.recipes_title'.tr()),

        backgroundColor: context.appColors.cardSurface,

        foregroundColor: context.appColors.textPrimary,

        elevation: 0,

      ),

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(

            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),

            child: TextField(

              controller: _searchCtrl,

              onChanged: (_) => setState(() {}),

              decoration: InputDecoration(

                hintText: 'search.search_recipes'.tr(),

                prefixIcon: const Icon(Icons.search_rounded),

                filled: true,

                fillColor: context.appColors.inputFieldBg,

                border: OutlineInputBorder(

                  borderRadius: AppBorderRadius.a16,

                  borderSide: const BorderSide(color: AppColors.border),

                ),

                enabledBorder: OutlineInputBorder(

                  borderRadius: AppBorderRadius.a16,

                  borderSide: const BorderSide(color: AppColors.border),

                ),

                contentPadding: AppPad.v12,

              ),

            ),

          ),

          Consumer<RecipeProvider>(

            builder: (context, provider, _) {

              final count = provider.isLoaded

                  ? _filteredRecipes(provider.allRecipes).length

                  : 0;

              return Padding(

                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),

                child: Row(

                  children: [

                    Expanded(

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(

                            'home.recipes_count'.tr(

                              namedArgs: {'n': '$count'},

                            ),

                            style: AppTextStyles.s18.copyWith(

                              fontWeight: FontWeight.w800,

                            ),

                          ),

                          Text(

                            'home.recipes_available'.tr(),

                            style: AppTextStyles.s12.copyWith(

                              color: context.appColors.textSecondary,

                            ),

                          ),

                        ],

                      ),

                    ),

                    _ToolbarIconButton(

                      icon: Icons.tune_rounded,

                      label: 'home.filter_btn'.tr(),

                      showBadge: _hasActiveFilters,

                      onTap: _openFilterSheet,

                    ),

                    AppGap.w8,

                    _ToolbarTextButton(

                      label: 'home.sort_btn'.tr(),

                      onTap: _openSortSheet,

                    ),

                  ],

                ),

              );

            },

          ),

          Expanded(child: _buildBody()),

        ],

      ),

    );

  }



  Widget _buildBody() {

    return Consumer<RecipeProvider>(

      builder: (context, provider, _) {

        if (provider.isLoading || provider.status == RecipeStatus.initial) {

          return const Center(child: CircularProgressIndicator());

        }



        if (provider.status == RecipeStatus.error) {

          return Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Text('😕', style: TextStyle(fontSize: 32)),

                AppGap.h8,

                Text(

                  'home.load_error'.tr(),

                  style:

                      AppTextStyles.s14.copyWith(color: context.appColors.textSecondary),

                ),

                AppGap.h8,

                TextButton(

                  onPressed: provider.reload,

                  child: Text(

                    'home.retry'.tr(),

                    style:

                        AppTextStyles.s14.copyWith(color: AppColors.primary),

                  ),

                ),

              ],

            ),

          );

        }



        final recipes = _filteredRecipes(provider.allRecipes);



        if (recipes.isEmpty) {

          final hasSearch = _searchCtrl.text.trim().isNotEmpty;

          return Center(

            child: Text(

              hasSearch ? 'search.no_results'.tr() : 'home.no_recipes'.tr(),

              style: AppTextStyles.s14.copyWith(color: context.appColors.textSecondary),

              textAlign: TextAlign.center,

            ),

          );

        }



        return LayoutBuilder(

          builder: (context, constraints) {

            final crossAxisCount = constraints.maxWidth >= 768 ? 3 : 2;

            final horizontalPadding = constraints.maxWidth >= 768 ? 24.0 : 20.0;

            const crossAxisSpacing = 12.0;

            const mainAxisSpacing = 16.0;

            const metaBlockHeight = 56.0;

            const gapBelowImage = 10.0;



            final cellWidth = (constraints.maxWidth -

                    horizontalPadding * 2 -

                    crossAxisSpacing * (crossAxisCount - 1)) /

                crossAxisCount;

            final imageHeight = cellWidth / (180 / 150);

            final mainAxisExtent =

                imageHeight + gapBelowImage + metaBlockHeight;



            return GridView.builder(

              padding: EdgeInsets.fromLTRB(

                horizontalPadding,

                0,

                horizontalPadding,

                24,

              ),

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: crossAxisCount,

                crossAxisSpacing: crossAxisSpacing,

                mainAxisSpacing: mainAxisSpacing,

                mainAxisExtent: mainAxisExtent,

              ),

              itemCount: recipes.length,

              itemBuilder: (_, i) => RecipeCardWidget(

                recipe: recipes[i],

                layout: RecipeCardLayout.grid,

              ),

            );

          },

        );

      },

    );

  }

}



class _ToolbarIconButton extends StatelessWidget {

  const _ToolbarIconButton({

    required this.icon,

    required this.label,

    required this.onTap,

    this.showBadge = false,

  });



  final IconData icon;

  final String label;

  final VoidCallback onTap;

  final bool showBadge;



  @override

  Widget build(BuildContext context) {

    return Material(

      color: context.appColors.cardSurface,

      borderRadius: AppBorderRadius.a12,

      child: InkWell(

        onTap: onTap,

        borderRadius: AppBorderRadius.a12,

        child: Container(

          width: 44,

          height: 44,

          decoration: BoxDecoration(

            borderRadius: AppBorderRadius.a12,

            border: Border.all(color: AppColors.border),

          ),

          child: Stack(

            alignment: Alignment.center,

            children: [

              Icon(icon, size: 22, color: context.appColors.textPrimary),

              if (showBadge)

                Positioned(

                  top: 8,

                  right: 8,

                  child: Container(

                    width: 8,

                    height: 8,

                    decoration: const BoxDecoration(

                      color: AppColors.primary,

                      shape: BoxShape.circle,

                    ),

                  ),

                ),

            ],

          ),

        ),

      ),

    );

  }

}



class _ToolbarTextButton extends StatelessWidget {

  const _ToolbarTextButton({

    required this.label,

    required this.onTap,

  });



  final String label;

  final VoidCallback onTap;



  @override

  Widget build(BuildContext context) {

    return Material(

      color: context.appColors.cardSurface,

      borderRadius: AppBorderRadius.a12,

      child: InkWell(

        onTap: onTap,

        borderRadius: AppBorderRadius.a12,

        child: Container(

          height: 44,

          padding: const EdgeInsets.symmetric(horizontal: 14),

          decoration: BoxDecoration(

            borderRadius: AppBorderRadius.a12,

            border: Border.all(color: AppColors.border),

          ),

          child: Row(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(Icons.sort_rounded, size: 20),

              AppGap.w6,

              Text(

                label,

                style: AppTextStyles.s12.copyWith(fontWeight: FontWeight.w700),

              ),

            ],

          ),

        ),

      ),

    );

  }

}


