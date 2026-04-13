import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/premium/model/comp_row.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/plan_toggle_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_comparison_table_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_cta_button_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_disclaimer_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_features_card_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_header_widget.dart';
import 'package:cravvy_cooking_app/modules/premium/widgets/premium_price_card_widget.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isAnnual = true;

  // Pricing constants
  static const int _annualPriceVND = 599000;
  static const int _monthlyPriceVND = 79000;
  static const int _annualMonthly = 49917; // 599000 / 12
  static const int _annualSavings = 349000; // (79000 * 12) - 599000
  static const int _savePct = 37;

  // Feature list
  static const List<String> _features = [
    'Unlimited AI-powered meal suggestions daily',
    'Advanced nutrition tracking & insights',
    'Access to 1000+ premium recipes',
    'Smart shopping lists with auto-sync',
    'Ad-free experience',
    'Priority customer support',
  ];

  // Comparison rows
  static const List<CompRow> _compRows = [
    CompRow('Daily meal suggestions', '3/day', 'Unlimited'),
    CompRow('AI meal plan duration', '3 days', '7–30 days'),
    CompRow('Calorie tracking', 'Basic', 'Advanced'),
    CompRow('Ads', 'Yes', 'No'),
    CompRow('Diet personalization', 'Limited', 'Full'),
    CompRow('Recipe collections', '100+', '1000+'),
    CompRow('Shopping lists', 'Basic', 'Smart'),
    CompRow('Priority support', '—', '✓'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppPad.h16v20,
                child: Column(
                  children: [
                    const PremiumHeaderWidget(),
                    AppGap.h24,
            
                    PremiumFeaturesCardWidget(features: _features),
                    AppGap.h20,
            
                    PremiumComparisonTableWidget(rows: _compRows),
                    AppGap.h24,
            
                    PlanToggleWidget(
                      isAnnual: _isAnnual,
                      savePct: _savePct,
                      onChanged: (value) => setState(() => _isAnnual = value),
                    ),
                    AppGap.h16,
            
                    PremiumPriceCardWidget(
                      isAnnual: _isAnnual,
                      annualPrice: _annualPriceVND,
                      monthlyPrice: _monthlyPriceVND,
                      annualMonthly: _annualMonthly,
                      annualSavings: _annualSavings,
                      savePct: _savePct,
                    ),
                    AppGap.h24,
            
                    PremiumCtaButtonWidget(
                      onPressed: () {
                        // TODO: handle subscription purchase
                      },
                    ),
                    AppGap.h8,
            
                    Text(
                      'Cancel anytime. No charges during trial.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppGap.h16,
            
                    const PremiumDisclaimerWidget(),
                    AppGap.h24,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
