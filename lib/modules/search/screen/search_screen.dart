import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _controller = TextEditingController();
  final List<String> _addedIngredients = [];
  bool _isSearching = false;

  static const _commonIngredients = [
    '🥚 Eggs', '🍗 Chicken', '🥦 Broccoli', '🍚 Rice',
    '🥑 Avocado', '🧀 Cheese', '🍅 Tomato', '🧄 Garlic',
    '🥕 Carrot', '🍋 Lemon', '🐟 Salmon', '🌽 Corn',
  ];

  static const _suggestedRecipes = [
    ('Egg Fried Rice', '350 kcal', '15 min', '🍳', 92),
    ('Chicken Stir-Fry', '420 kcal', '20 min', '🥘', 87),
    ('Avocado Omelette', '310 kcal', '12 min', '🥗', 78),
    ('Garlic Broccoli', '180 kcal', '10 min', '🥦', 65),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient(String item) {
    final clean = item.contains(' ')
        ? item.substring(item.indexOf(' ') + 1)
        : item;
    if (!_addedIngredients.contains(clean)) {
      setState(() => _addedIngredients.add(clean));
    }
  }

  void _removeIngredient(String item) =>
      setState(() => _addedIngredients.remove(item));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What\'s in your\nfridge? 🛒',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Add ingredients to get recipe ideas',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input tabs
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
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
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
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TypeTab(
                    controller: _controller,
                    addedIngredients: _addedIngredients,
                    commonIngredients: _commonIngredients,
                    suggestedRecipes: _suggestedRecipes,
                    onAdd: _addIngredient,
                    onRemove: _removeIngredient,
                  ),
                  _ComingSoonTab(icon: '📷', label: 'Scan ingredients'),
                  _ComingSoonTab(icon: '🎙️', label: 'Voice input'),
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
  final TextEditingController controller;
  final List<String> addedIngredients;
  final List<String> commonIngredients;
  final List<(String, String, String, String, int)> suggestedRecipes;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TypeTab({
    required this.controller,
    required this.addedIngredients,
    required this.commonIngredients,
    required this.suggestedRecipes,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type an ingredient...',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textHint),
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      onAdd(v.trim());
                      controller.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onAdd(controller.text.trim());
                    controller.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Added ingredients chips
          if (addedIngredients.isNotEmpty) ...[
            Text('Added (${addedIngredients.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: addedIngredients.map((item) => Chip(
                label: Text(item),
                labelStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
                backgroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primary, width: 1),
                deleteIcon: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.primary),
                onDeleted: () => onRemove(item),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Common ingredients
          Text('Common ingredients',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonIngredients.map((item) {
              final clean = item.substring(item.indexOf(' ') + 1);
              final isAdded = addedIngredients.contains(clean);
              return GestureDetector(
                onTap: () => onAdd(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
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
                    style: TextStyle(
                      fontFamily: 'Nunito',
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

          // Suggested recipes
          if (addedIngredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Recipe Suggestions',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${suggestedRecipes.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestedRecipes.map((r) => _RecipeSuggestionTile(recipe: r)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _RecipeSuggestionTile extends StatelessWidget {
  final (String, String, String, String, int) recipe;
  const _RecipeSuggestionTile({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final (name, cal, time, emoji, match) = recipe;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji,
                style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 13, color: AppColors.primary),
                    Text(' $cal · ⏱ $time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary, fontSize: 11,
                        )),
                  ],
                ),
              ],
            ),
          ),
          // Match percentage
          Column(
            children: [
              Text(
                '$match%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              Text('match',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String icon;
  final String label;
  const _ComingSoonTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(label,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Coming soon in the next update',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
