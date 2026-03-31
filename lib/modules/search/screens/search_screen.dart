import 'package:cravvy_cooking_app/init.dart';
import '../widgets/type_tab.dart';
import '../widgets/coming_soon_tab_widget.dart';

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
              padding: const EdgeInsets.only(
                left: 24,
                top: 20,
                right: 24,
              ), //TODO: no AppPad equivalent for this multi-directional EdgeInsets.only
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s in your\nfridge? 🛒',
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

            // Tab bar
            Padding(
              padding: AppPad.h16,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppBorderRadius.a14,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppBorderRadius.a12,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.06,
                        ), // no AppColors equivalent for 0.06 opacity
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
            AppGap.h16,

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TypeTab(
                    controller: _controller,
                    addedIngredients: _addedIngredients,
                    commonIngredients: _commonIngredients,
                    suggestedRecipes: _suggestedRecipes,
                    onAdd: _addIngredient,
                    onRemove: _removeIngredient,
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
