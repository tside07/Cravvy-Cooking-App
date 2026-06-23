import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/core/utils/profile_recipe_filter.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/search/provider/ingredient_suggest_provider.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_sheet_state_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/coming_soon_tab_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/type_tab.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider must sit ABOVE the stateful view so context.read inside the
    // State (e.g. _suggestAi) can find it.
    return ChangeNotifierProvider(
      create: (_) => IngredientSuggestProvider(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _ingredientCtrl = TextEditingController();
  final List<String> _addedIngredients = [];

  String? _filterMealType;
  int? _filterMaxCalories;
  String? _filterDifficulty;

  /// Set once the user accepts the risk of ingredients that clash with their
  /// profile. Reset whenever the ingredient set changes.
  bool _riskAcknowledged = false;

  List<IngredientConflict> _conflicts() {
    final user = context.read<AuthProvider>().user;
    if (user == null || _addedIngredients.isEmpty) return const [];
    return ProfileRecipeFilter.detectInputConflicts(
      ingredients: _addedIngredients,
      diets: user.diets,
      avoidFoods: user.avoidFoods,
    );
  }

  bool get _hasActiveFilter =>
      _filterMealType != null ||
      _filterMaxCalories != null ||
      _filterDifficulty != null;

  /// Keys khớp với JSON search.ingredient.* — đã là text thuần (không emoji)
  List<String> get _commonIngredients => [
    'search.ingredient.eggs'.tr(),
    'search.ingredient.chicken'.tr(),
    'search.ingredient.broccoli'.tr(),
    'search.ingredient.rice'.tr(),
    'search.ingredient.avocado'.tr(),
    'search.ingredient.cheese'.tr(),
    'search.ingredient.tomato'.tr(),
    'search.ingredient.garlic'.tr(),
    'search.ingredient.carrot'.tr(),
    'search.ingredient.lemon'.tr(),
    'search.ingredient.salmon'.tr(),
    'search.ingredient.corn'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
  }

  void _addIngredient(String item) {
    final clean = item.trim();
    if (!_addedIngredients.contains(clean)) {
      setState(() {
        _addedIngredients.add(clean);
        _riskAcknowledged = false; // re-confirm after any change
      });
      _doSearch(clean);
    }
  }

  void _removeIngredient(String item) {
    setState(() {
      _addedIngredients.remove(item);
      _riskAcknowledged = false;
    });
    if (_addedIngredients.isEmpty) {
      context.read<RecipeProvider>().clearSearch();
    } else {
      _doSearch(_addedIngredients.join(' '));
    }
  }

  void _doSearch(String query) {
    context.read<RecipeProvider>().search(query);
  }

  void _suggestAi() {
    if (_addedIngredients.isEmpty) return;
    // Block until the user accepts the risk of profile-conflicting ingredients.
    if (_conflicts().isNotEmpty && !_riskAcknowledged) return;
    context.read<IngredientSuggestProvider>().suggest(
          ingredients: _addedIngredients,
          locale: context.locale.languageCode,
        );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterSheet(
        selectedMealType: _filterMealType,
        selectedMaxCal: _filterMaxCalories,
        selectedDifficulty: _filterDifficulty,
        onApply: (mealType, maxCal, difficulty) {
          setState(() {
            _filterMealType = mealType;
            _filterMaxCalories = maxCal;
            _filterDifficulty = difficulty;
          });
          if (_searchCtrl.text.isNotEmpty) _doSearch(_searchCtrl.text);
        },
        onReset: () {
          setState(() {
            _filterMealType = null;
            _filterMaxCalories = null;
            _filterDifficulty = null;
          });
          if (_searchCtrl.text.isNotEmpty) _doSearch(_searchCtrl.text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final appColors = context.appColors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              title: 'search.title'.tr(),
              subtitle: 'search.subtitle'.tr(),
            ),
            AppGap.h16,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: appColors.cardSurface,
                  borderRadius: AppBorderRadius.button,
                  border: Border.all(color: appColors.borderDivider),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: appColors.elevated,
                    borderRadius: AppBorderRadius.card,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: appColors.textSecondary,
                  tabs: [
                    Tab(text: 'search.tab_type'.tr()),
                    Tab(text: 'search.tab_scan'.tr()),
                    Tab(text: 'search.tab_voice'.tr()),
                  ],
                ),
              ),
            ),
            AppGap.h16,
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TypeTab(
                    searchCtrl: _searchCtrl,
                    ingredientCtrl: _ingredientCtrl,
                    addedIngredients: _addedIngredients,
                    commonIngredients: _commonIngredients,
                    onAdd: _addIngredient,
                    onRemove: _removeIngredient,
                    onSearchChanged: _doSearch,
                    onFilterTap: _showFilterSheet,
                    onSuggestAi: _suggestAi,
                    conflicts: _conflicts(),
                    riskAcknowledged: _riskAcknowledged,
                    onAcknowledgeRisk: () =>
                        setState(() => _riskAcknowledged = true),
                    hasActiveFilter: _hasActiveFilter,
                    filterMealType: _filterMealType,
                    filterMaxCalories: _filterMaxCalories,
                    filterDifficulty: _filterDifficulty,
                  ),
                  ComingSoonTabWidget(
                    icon: Icons.photo_camera_rounded,
                    label: 'search.tab_scan'.tr(),
                  ),
                  ComingSoonTabWidget(
                    icon: Icons.mic_rounded,
                    label: 'search.tab_voice'.tr(),
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
