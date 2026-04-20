import 'package:cravvy_cooking_app/init.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String recipeName;
  final String recipeId;
  bool checked;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.recipeName,
    required this.recipeId,
    this.checked = false,
  });
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingItem> _items = [
    ShoppingItem(id: '1', name: '2 salmon fillets (150g each)', recipeName: 'Baked Salmon', recipeId: 'r1'),
    ShoppingItem(id: '2', name: '200g broccoli florets', recipeName: 'Baked Salmon', recipeId: 'r1'),
    ShoppingItem(id: '3', name: '1 lemon', recipeName: 'Baked Salmon', recipeId: 'r1'),
    ShoppingItem(id: '4', name: '3 garlic cloves', recipeName: 'Baked Salmon', recipeId: 'r1'),
    ShoppingItem(id: '5', name: '2 cups oats', recipeName: 'Overnight Oats', recipeId: 'r2'),
    ShoppingItem(id: '6', name: '1 cup almond milk', recipeName: 'Overnight Oats', recipeId: 'r2'),
    ShoppingItem(id: '7', name: '2 tbsp chia seeds', recipeName: 'Overnight Oats', recipeId: 'r2'),
    ShoppingItem(id: '8', name: '1 banana', recipeName: 'Overnight Oats', recipeId: 'r2'),
  ];

  Map<String, List<ShoppingItem>> get _grouped {
    final map = <String, List<ShoppingItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.recipeId, () => []).add(item);
    }
    return map;
  }

  String? _recipeNameOf(String id) => _items.firstWhere((i) => i.recipeId == id, orElse: () => _items.first).recipeName;

  int get _checkedCount => _items.where((i) => i.checked).length;
  double get _progress => _items.isEmpty ? 0 : _checkedCount / _items.length;

  void _toggle(String id) => setState(() => _items.firstWhere((i) => i.id == id).checked = !_items.firstWhere((i) => i.id == id).checked);
  void _remove(String id) => setState(() => _items.removeWhere((i) => i.id == id));
  void _clearChecked() => setState(() => _items.removeWhere((i) => i.checked));
  void _clearAll() => setState(() => _items.clear());

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return _EmptyState();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shopping List', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
                            Text('$_checkedCount of ${_items.length} items', style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: _showShareDialog,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'clear_checked') _clearChecked();
                          if (v == 'clear_all') _showClearAllDialog();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'clear_checked', child: Text('Clear checked')),
                          const PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
                        ],
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.success,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _grouped.length,
                itemBuilder: (context, groupIndex) {
                  final recipeId = _grouped.keys.elementAt(groupIndex);
                  final items = _grouped[recipeId]!;
                  final recipeName = _recipeNameOf(recipeId);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(recipeName ?? '', style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Column(
                          children: items.asMap().entries.map((e) {
                            final item = e.value;
                            final isLast = e.key == items.length - 1;
                            return _ShoppingItemTile(
                              item: item,
                              isLast: isLast,
                              onToggle: () => _toggle(item.id),
                              onRemove: () => _remove(item.id),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),

            // Bottom action
            if (_checkedCount > 0)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _clearChecked,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: Text('Clear $_checkedCount checked'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share Shopping List', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy to clipboard'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Items?'),
        content: const Text('This will remove all items from your shopping list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _clearAll(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _ShoppingItemTile({required this.item, required this.isLast, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(16),
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.checked ? AppColors.success : Colors.transparent,
                    border: Border.all(color: item.checked ? AppColors.success : AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: item.checked
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTextStyles.s14.copyWith(
                      color: item.checked ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: item.checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onRemove,
                  color: AppColors.textHint,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 52, color: AppColors.border),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Shopping List', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_cart_outlined, size: 44, color: AppColors.textHint),
              ),
              const SizedBox(height: 24),
              Text('Your list is empty', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Add ingredients from recipes to build your shopping list',
                  textAlign: TextAlign.center, style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.app),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Browse Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
