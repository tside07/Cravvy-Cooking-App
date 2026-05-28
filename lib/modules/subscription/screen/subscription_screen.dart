import 'package:cravvy_cooking_app/init.dart';

class _Plan {
  final String id;
  final String name;
  final String priceLabel;
  final String priceNote;
  final String? badge;
  final bool highlight;
  const _Plan({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.priceNote,
    this.badge,
    this.highlight = false,
  });
}

class _FeatureRow {
  final String label;
  final String freeVal;
  final String premiumVal;
  final bool freeCheck;
  final bool premiumCheck;

  const _FeatureRow({
    required this.label,
    this.freeVal = '',
    this.premiumVal = '',
    this.freeCheck = false,
    this.premiumCheck = false,
  });
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'annual';

  static const _plans = [
    _Plan(id: 'free', name: 'Free', priceLabel: 'Free', priceNote: 'Forever'),
    _Plan(id: 'monthly', name: 'Premium Monthly', priceLabel: '149.000đ', priceNote: 'per month'),
    _Plan(id: 'annual', name: 'Premium Annual', priceLabel: '999.000đ', priceNote: 'per year', badge: 'Save 44%', highlight: true),
  ];

  static const _highlights = [
    _Highlight(icon: Icons.auto_awesome_outlined, color: Color(0xFFF77C0F), title: 'Smart AI Chef', desc: 'Personalized 30-day menu based on your body, goals and taste'),
    _Highlight(icon: Icons.swap_horiz_rounded, color: Color(0xFF6A8A42), title: 'Unlimited Meal Swap', desc: 'Replace any meal with a tap, matched to fridge ingredients'),
    _Highlight(icon: Icons.bar_chart_rounded, color: Color(0xFFD97706), title: 'Deep Nutrition Analysis', desc: 'Track 20+ micronutrients and get weekly adjustment reports'),
    _Highlight(icon: Icons.block_rounded, color: Color(0xFF6B7280), title: 'Ad-Free Experience', desc: 'Pure cooking focus, no interruptions'),
  ];

  static const _features = [
    _FeatureRow(label: 'AI meal suggestions', freeVal: '3/day', premiumVal: 'Unlimited'),
    _FeatureRow(label: 'Meal plan duration', freeVal: '3 days', premiumVal: '7–30 days'),
    _FeatureRow(label: 'Meal Swap', freeVal: '2×/week', premiumVal: 'Unlimited'),
    _FeatureRow(label: 'Calorie tracking', freeVal: 'Basic', premiumVal: 'Advanced'),
    _FeatureRow(label: 'Macro analysis', freeCheck: false, premiumCheck: true),
    _FeatureRow(label: 'AI Nutrition Chatbot', freeCheck: false, premiumCheck: true),
    _FeatureRow(label: 'Recipe library', freeVal: '100+', premiumVal: '1,000+'),
    _FeatureRow(label: 'Smart shopping list', freeVal: 'Basic', premiumVal: 'Advanced'),
    _FeatureRow(label: 'Ad-free', freeCheck: false, premiumCheck: true),
    _FeatureRow(label: 'Priority support', freeCheck: false, premiumCheck: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
                  Text('Subscription Plans', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text('Go Premium', style: AppTextStyles.s20.copyWith(fontWeight: FontWeight.w800, fontSize: 28)),
                          const SizedBox(height: 8),
                          Text('Cook smarter, eat healthier', style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Plan cards
                    ...List.generate(_plans.length, (i) {
                      final plan = _plans[i];
                      final isSelected = _selectedPlan == plan.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPlan = plan.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12)] : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(plan.name, style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700)),
                                          if (plan.badge != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                                              child: Text(plan.badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(plan.priceNote, style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(plan.priceLabel, style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Highlights
                    Text('What you get', style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._highlights.map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HighlightTile(highlight: h),
                        )),

                    const SizedBox(height: 24),

                    // Comparison table
                    Text('Compare Plans', style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text('Feature', style: AppTextStyles.s12.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                                Expanded(child: Center(child: Text('Free', style: AppTextStyles.s12.copyWith(fontWeight: FontWeight.w700)))),
                                Expanded(child: Center(child: Text('Premium', style: AppTextStyles.s12.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)))),
                              ],
                            ),
                          ),
                          ..._features.asMap().entries.map((e) {
                            final row = e.value;
                            final isLast = e.key == _features.length - 1;
                            return _FeatureTileRow(row: row, isLast: isLast);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedPlan == 'free'
                          ? null
                          : () => context.push(AppRouter.trialActivation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _selectedPlan == 'free' ? 'Current Plan' : 'Start 14-Day Free Trial',
                        style: AppTextStyles.s16.copyWith(
                          color: _selectedPlan == 'free' ? AppColors.textSecondary : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Cancel anytime · No charges during trial',
                      style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Highlight {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _Highlight({required this.icon, required this.color, required this.title, required this.desc});
}

class _HighlightTile extends StatelessWidget {
  final _Highlight highlight;
  const _HighlightTile({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: highlight.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(highlight.icon, color: highlight.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(highlight.title, style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(highlight.desc, style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTileRow extends StatelessWidget {
  final _FeatureRow row;
  final bool isLast;
  const _FeatureTileRow({required this.row, required this.isLast});

  Widget _cell(String val, bool check, bool isPremium) {
    if (val.isNotEmpty) {
      return Text(val, style: AppTextStyles.s12.copyWith(color: isPremium ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center);
    }
    return Icon(check ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 18, color: check ? (isPremium ? AppColors.primary : AppColors.textHint) : AppColors.border);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(row.label, style: AppTextStyles.s14.copyWith(color: AppColors.textPrimary))),
              Expanded(child: Center(child: _cell(row.freeVal, row.freeCheck, false))),
              Expanded(child: Center(child: _cell(row.premiumVal, row.premiumCheck, true))),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 16, color: AppColors.border),
      ],
    );
  }
}

