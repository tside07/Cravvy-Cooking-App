import 'package:cravvy_cooking_app/core/routes/all_recipes_args.dart';
import 'package:cravvy_cooking_app/data/models/recipe.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/home/widgets/recipe_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key, required this.args});

  final AllRecipesArgs args;

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  late String _mealType;
  final _searchCtrl = TextEditingController();

  static const _typeTabs = [
    ('all', 'home.tab_all', '🍽️'),
    ('breakfast', 'home.tab_breakfast', '🌅'),
    ('lunch', 'home.tab_lunch', '☀️'),
    ('dinner', 'home.tab_dinner', '🌙'),
    ('snack', 'home.tab_snack', '🍎'),
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

  List<Recipe> _filteredRecipes(List<Recipe> all) {
    var list = all;
    if (_mealType != 'all') {
      list = list.where((r) => r.mealType == _mealType).toList(growable: false);
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q)) ||
          (r.description?.toLowerCase().contains(q) ?? false);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('home.recipes_title'.tr()),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
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
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _typeTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (type, labelKey, emoji) = _typeTabs[i];
                final isSelected = _mealType == type;
                return GestureDetector(
                  onTap: () => setState(() => _mealType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '$emoji ${labelKey.tr()}',
                      style: AppTextStyles.s12.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AppGap.h12,
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
                      AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
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
              style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 768 ? 3 : 2;
            final horizontalPadding = constraints.maxWidth >= 768 ? 24.0 : 20.0;

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                24,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
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
