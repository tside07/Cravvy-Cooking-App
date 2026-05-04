import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/recipe_search_result_tile.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/coming_soon_tab_widget.dart';
import 'package:shimmer/shimmer.dart';

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

  static const _commonIngredients = [
    '🥚 Eggs',
    '🍗 Chicken',
    '🥦 Broccoli',
    '🍚 Rice',
    '🥑 Avocado',
    '🧀 Cheese',
    '🍅 Tomato',
    '🧄 Garlic',
    '🥕 Carrot',
    '🍋 Lemon',
    '🐟 Salmon',
    '🌽 Corn',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 20, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's in your\nfridge? 🛒",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  AppGap.h4,
                  Text(
                    'Add ingredients to get recipe ideas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            AppGap.h20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                      ),
                    ],
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
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: '⌨️  Type'),
                    Tab(text: '📷  Scan'),
                    Tab(text: '🎙️  Voice'),
                  ],
                ),
              ),
            ),
            AppGap.h16,
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TypeTab(
                    searchCtrl: _searchCtrl,
                    ingredientCtrl: _ingredientCtrl,
                    addedIngredients: _addedIngredients,
                    commonIngredients: _commonIngredients,
                    onAdd: _addIngredient,
                    onRemove: _removeIngredient,
                    onSearchChanged: _doSearch,
                  ),
                  const ComingSoonTabWidget(
                    icon: '📷',
                    label: 'Scan ingredients',
                  ),
                  const ComingSoonTabWidget(icon: '🎙️', label: 'Voice input'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.searchCtrl,
    required this.ingredientCtrl,
    required this.addedIngredients,
    required this.commonIngredients,
    required this.onAdd,
    required this.onRemove,
    required this.onSearchChanged,
  });

  final TextEditingController searchCtrl;
  final TextEditingController ingredientCtrl;
  final List<String> addedIngredients;
  final List<String> commonIngredients;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    hintStyle: AppTextStyles.s14.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              AppGap.h16,

              // Ingredient input
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: ingredientCtrl,
                        decoration: InputDecoration(
                          hintText: 'Add ingredient (e.g. Chicken)',
                          hintStyle: AppTextStyles.s14.copyWith(
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            onAdd(v.trim());
                            ingredientCtrl.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final v = ingredientCtrl.text.trim();
                        if (v.isNotEmpty) {
                          onAdd(v);
                          ingredientCtrl.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              AppGap.h16,

              // Added chips
              if (addedIngredients.isNotEmpty) ...[
                Text(
                  'Added (${addedIngredients.length})',
                  style: AppTextStyles.s14.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: addedIngredients
                      .map(
                        (item) => Chip(
                          label: Text(item),
                          labelStyle: AppTextStyles.s14.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                          backgroundColor: AppColors.primaryLight,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          deleteIcon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onDeleted: () => onRemove(item),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      )
                      .toList(),
                ),
                AppGap.h16,
              ],

              // Common ingredients
              Text(
                'Common ingredients',
                style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
              ),
              AppGap.h10,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonIngredients.map((item) {
                  final clean = item.contains(' ')
                      ? item.substring(item.indexOf(' ') + 1)
                      : item;
                  final isAdded = addedIngredients.contains(clean);
                  return GestureDetector(
                    onTap: () => onAdd(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAdded ? AppColors.primary : AppColors.border,
                          width: isAdded ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        item,
                        style: AppTextStyles.s14.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isAdded
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Search results
              if (provider.searchQuery.isNotEmpty) ...[
                AppGap.h24,
                Row(
                  children: [
                    Text(
                      'Recipe Results',
                      style: AppTextStyles.s18.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppGap.w8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.searchResults.length}',
                        style: AppTextStyles.s12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,
                if (provider.isLoading)
                  ...List.generate(
                    3,
                    (_) => Shimmer.fromColors(
                      baseColor: AppColors.border,
                      highlightColor: AppColors.surface,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  )
                else if (provider.searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 32)),
                          AppGap.h8,
                          Text(
                            'Không tìm thấy món phù hợp',
                            style: AppTextStyles.s14.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.searchResults.map(
                    (r) => RecipeSearchResultTile(recipe: r),
                  ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
