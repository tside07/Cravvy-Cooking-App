import 'package:cravvy_cooking_app/init.dart';

class _FAQItem {
  final String q;
  final String a;
  const _FAQItem({required this.q, required this.a});
}

class _FAQCategory {
  final String id;
  final String emoji;
  final String label;
  final List<_FAQItem> items;
  const _FAQCategory({required this.id, required this.emoji, required this.label, required this.items});
}

const _faqData = [
  _FAQCategory(
    id: 'general', emoji: '🍳', label: 'General',
    items: [
      _FAQItem(q: 'What is Cravvy?', a: 'Cravvy is an AI cooking assistant app designed for health-conscious users. It works like an "AI Cooking Assistant" – suggesting personalized menus based on your health goals, helping eliminate the daily "what should I eat?" dilemma.'),
      _FAQItem(q: 'Is Cravvy free?', a: 'Yes! Cravvy operates on a Freemium model. The Free plan includes 100+ recipes, a 3-day meal plan view, 2 meal swaps per week, and 1 AI menu refresh per week. Premium (149,000đ/month or 999,000đ/year) adds 5 swaps/week, 3 AI refreshes/week, a 7-day plan, and an expanded recipe library.'),
      _FAQItem(q: 'Does Cravvy support all diets?', a: 'Cravvy supports many diets: Unrestricted, Eat Clean, Vegan, Vegetarian, Keto, Paleo, Mediterranean, Gluten-Free, and Dairy-Free. You can change your diet preference anytime in Settings.'),
      _FAQItem(q: 'Is my data safe?', a: 'Cravvy is committed to protecting user data. Personal information (name, email, health metrics) is encrypted and never shared with third parties. You can export or delete all your data anytime in Settings → Privacy.'),
    ],
  ),
  _FAQCategory(
    id: 'ai', emoji: '🤖', label: 'AI Features',
    items: [
      _FAQItem(q: 'How does AI suggest meals?', a: 'Cravvy\'s AI analyzes your profile (goal, diet, allergies) to build a weekly menu. Free users can refresh the AI plan once per week; Premium users get up to 3 refreshes per week.'),
      _FAQItem(q: 'How does Meal Swap work?', a: 'Meal Swap replaces a meal with another from the same category. Free: 2 swaps per week. Premium: 5 swaps per week — enough flexibility without overloading our servers.'),
      _FAQItem(q: 'What is the AI Nutrition Chatbot?', a: 'The AI Nutrition Chatbot (Premium) is an assistant that answers questions like "What should I eat to build muscle?" or "What can I substitute for egg whites?" instantly, based on verified nutritional data.'),
    ],
  ),
  _FAQCategory(
    id: 'account', emoji: '👤', label: 'Account & Billing',
    items: [
      _FAQItem(q: 'How do I cancel my subscription?', a: 'You can cancel anytime from Settings → Subscription → Manage Plan. Your Premium access remains active until the end of the current billing period. No partial refunds are issued.'),
      _FAQItem(q: 'Can I change my email or password?', a: 'Yes. Go to Profile → Edit Profile to update your name or email. To change your password, go to Settings → Change Password. You\'ll receive a verification code to your current email.'),
      _FAQItem(q: 'What happens to my data if I delete my account?', a: 'Deleting your account permanently erases all your personal data, meal history, and preferences. This action cannot be undone. You can export your data first via Settings → Export My Data.'),
    ],
  ),
  _FAQCategory(
    id: 'technical', emoji: '⚙️', label: 'Technical',
    items: [
      _FAQItem(q: 'Does Cravvy work offline?', a: 'Some features like saved recipes and your meal plan are available offline. AI suggestions, Meal Swap, and the Nutrition Chatbot require an internet connection.'),
      _FAQItem(q: 'How do I report a bug?', a: 'Use Settings → Help & Feedback to submit a bug report. Include as much detail as possible (screen, steps to reproduce, device model). Our team typically responds within 24 hours.'),
    ],
  ),
];

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String _selectedCategory = 'general';
  String _searchQuery = '';
  final Set<String> _expanded = {};
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FAQItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _faqData.firstWhere((c) => c.id == _selectedCategory).items;
    }
    final q = _searchQuery.toLowerCase();
    return _faqData.expand((c) => c.items).where((item) => item.q.toLowerCase().contains(q) || item.a.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
                      Text('FAQ', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search questions...',
                        hintStyle: AppTextStyles.s14.copyWith(color: AppColors.textHint),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textHint), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category tabs
                  if (_searchQuery.isEmpty)
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: _faqData.map((cat) {
                          final isSelected = _selectedCategory == cat.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${cat.emoji} ${cat.label}',
                                  style: AppTextStyles.s14.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.border),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _filteredItems.isEmpty
                  ? _EmptySearch()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, i) {
                        final item = _filteredItems[i];
                        final key = '${_selectedCategory}_$i';
                        final isExpanded = _expanded.contains(key);
                        return _FAQTile(
                          item: item,
                          isExpanded: isExpanded,
                          onTap: () => setState(() {
                            if (isExpanded) _expanded.remove(key);
                            else _expanded.add(key);
                          }),
                        );
                      },
                    ),
            ),

            // Contact
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Still have questions?', style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700)),
                        Text('Contact support@cravvy.app', style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final _FAQItem item;
  final bool isExpanded;
  final VoidCallback onTap;
  const _FAQTile({required this.item, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: isExpanded ? Border.all(color: AppColors.primary.withOpacity(0.25)) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.q, style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: isExpanded ? AppColors.primary : AppColors.textHint),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                Divider(color: AppColors.border),
                const SizedBox(height: 10),
                Text(item.a, style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary, height: 1.6)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text('No results found', style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Try a different keyword', style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

