import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cravvy_cooking_app/core/widgets/template/custom_app_bar.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_sheet_state_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/coming_soon_tab_widget.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/type_tab.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _ingredientCtrl = TextEditingController();
  final List<String> _addedIngredients = [];

  String? _filterMealType;
  int? _filterMaxCalories;
  String? _filterDifficulty;

  bool get _hasActiveFilter =>
      _filterMealType != null ||
      _filterMaxCalories != null ||
      _filterDifficulty != null;

  /// Keys khớp với JSON search.ingredient.*
  /// Giá trị clean (không có emoji) dùng để match với _addedIngredients
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
    final clean = item.contains(' ')
        ? item.substring(item.indexOf(' ') + 1)
        : item;
    if (!_addedIngredients.contains(clean)) {
      setState(() => _addedIngredients.add(clean));
      _doSearch(clean);
    }
  }

  void _removeIngredient(String item) {
    setState(() => _addedIngredients.remove(item));
    if (_addedIngredients.isEmpty) {
      context.read<RecipeProvider>().clearSearch();
    } else {
      _doSearch(_addedIngredients.join(' '));
    }
  }

  void _doSearch(String query) {
    context.read<RecipeProvider>().search(query);
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
                    hasActiveFilter: _hasActiveFilter,
                    filterMealType: _filterMealType,
                    filterMaxCalories: _filterMaxCalories,
                    filterDifficulty: _filterDifficulty,
                  ),
                  ComingSoonTabWidget(
                    icon: '📷',
                    label: 'search.tab_scan'.tr(),
                  ),
                  ComingSoonTabWidget(
                    icon: '🎙️',
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
