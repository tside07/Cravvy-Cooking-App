import 'package:cravvy_cooking_app/init.dart';

import 'package:easy_localization/easy_localization.dart';

class _FAQItem {
  final String q;

  final String a;

  const _FAQItem({required this.q, required this.a});
}

class _FAQCategory {
  final String id;

  final String label;

  final List<_FAQItem> items;

  const _FAQCategory({
    required this.id,

    required this.label,

    required this.items,
  });
}

List<_FAQCategory> _buildFaqData() => [
  _FAQCategory(
    id: 'general',


    label: 'faq.cat_general'.tr(),

    items: [
      _FAQItem(q: 'faq.q_what_is'.tr(), a: 'faq.a_what_is'.tr()),

      _FAQItem(q: 'faq.q_free'.tr(), a: 'faq.a_free'.tr()),

      _FAQItem(q: 'faq.q_diets'.tr(), a: 'faq.a_diets'.tr()),

      _FAQItem(q: 'faq.q_data'.tr(), a: 'faq.a_data'.tr()),
    ],
  ),

  _FAQCategory(
    id: 'ai',

    label: 'faq.cat_ai'.tr(),

    items: [
      _FAQItem(q: 'faq.q_ai_suggest'.tr(), a: 'faq.a_ai_suggest'.tr()),

      _FAQItem(q: 'faq.q_swap'.tr(), a: 'faq.a_swap'.tr()),

      _FAQItem(q: 'faq.q_chatbot'.tr(), a: 'faq.a_chatbot'.tr()),
    ],
  ),

  _FAQCategory(
    id: 'account',

    label: 'faq.cat_account'.tr(),

    items: [
      _FAQItem(q: 'faq.q_cancel'.tr(), a: 'faq.a_cancel'.tr()),

      _FAQItem(q: 'faq.q_change_email'.tr(), a: 'faq.a_change_email'.tr()),

      _FAQItem(q: 'faq.q_delete'.tr(), a: 'faq.a_delete'.tr()),
    ],
  ),

  _FAQCategory(
    id: 'technical',

    label: 'faq.cat_technical'.tr(),

    items: [
      _FAQItem(q: 'faq.q_offline'.tr(), a: 'faq.a_offline'.tr()),

      _FAQItem(q: 'faq.q_bug'.tr(), a: 'faq.a_bug'.tr()),
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
    final faqData = _buildFaqData();

    if (_searchQuery.isEmpty) {
      return faqData.firstWhere((c) => c.id == _selectedCategory).items;
    }

    final q = _searchQuery.toLowerCase();

    return faqData
        .expand((c) => c.items)
        .where(
          (item) =>
              item.q.toLowerCase().contains(q) ||
              item.a.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final faqData = _buildFaqData();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),

              color: colors.cardSurface,

              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),

                        onPressed: () => context.pop(),
                      ),

                      Text(
                        'faq.title'.tr(),

                        style: context.themed(
                          AppTextStyles.s18,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),

                    decoration: BoxDecoration(
                      color: colors.inputFieldBg,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: TextField(
                      controller: _searchController,

                      onChanged: (v) => setState(() => _searchQuery = v),

                      style: context.themed(AppTextStyles.s14),

                      decoration: InputDecoration(
                        hintText: 'faq.search_hint'.tr(),

                        hintStyle: AppTextStyles.s14.copyWith(
                          color: colors.inputHint,
                        ),

                        prefixIcon: Icon(
                          Icons.search_rounded,

                          color: colors.inputHint,
                        ),

                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,

                                  color: colors.inputHint,
                                ),

                                onPressed: () {
                                  _searchController.clear();

                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,

                        border: InputBorder.none,

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
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

                        children: faqData.map((cat) {
                          final isSelected = _selectedCategory == cat.id;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat.id),

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),

                              margin: const EdgeInsets.only(right: 8),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,

                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : colors.chipBg,

                                borderRadius: AppBorderRadius.chip,
                              ),

                              child: Text(
                                cat.label,

                                style: AppTextStyles.s14.copyWith(
                                  color: isSelected
                                      ? colors.onPrimary
                                      : colors.textSecondary,

                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Divider(height: 1, color: colors.borderDivider),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _filteredItems.isEmpty
                  ? const _EmptySearch()
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
                            if (isExpanded) {
                              _expanded.remove(key);
                            } else {
                              _expanded.add(key);
                            }
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

                borderRadius: AppBorderRadius.card,

                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 42,

                    height: 42,

                    decoration: const BoxDecoration(
                      color: AppColors.primary,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.mail_outline_rounded,

                      color: Colors.white,

                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'faq.contact_title'.tr(),

                          style: AppTextStyles.s14.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          'faq.contact_email'.tr(),

                          style: AppTextStyles.s12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,

                    size: 14,

                    color: AppColors.primary,
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

class _FAQTile extends StatelessWidget {
  final _FAQItem item;

  final bool isExpanded;

  final VoidCallback onTap;

  const _FAQTile({
    required this.item,

    required this.isExpanded,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: context
          .cardBox()
          .copyWith(
            border: isExpanded
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
                : null,
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
                  Expanded(
                    child: Text(
                      item.q,

                      style: context.themed(
                        AppTextStyles.s14,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,

                    duration: const Duration(milliseconds: 200),

                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: isExpanded
                          ? AppColors.primary
                          : colors.textDisabled,
                    ),
                  ),
                ],
              ),

              if (isExpanded) ...[
                const SizedBox(height: 10),

                Divider(color: colors.borderDivider),

                const SizedBox(height: 10),

                Text(
                  item.a,

                  style: context
                      .themed(AppTextStyles.s14, color: colors.textSecondary)
                      .copyWith(height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.search_off_rounded,

              size: 48,

              color: colors.textDisabled,
            ),

            const SizedBox(height: 12),

            Text(
              'faq.no_results'.tr(),

              style: context.themed(
                AppTextStyles.s16,

                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'faq.no_results_desc'.tr(),

              style: context.themed(
                AppTextStyles.s14,

                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
