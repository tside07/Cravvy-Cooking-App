import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
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
  static const int _annualPriceVND = 999000;
  static const int _monthlyPriceVND = 149000;
  static const int _annualMonthly = 83250; // 999000 / 12
  static const int _annualSavings = 789000; // (149000 * 12) - 999000
  static const int _savePct = 44;

  // Feature list
  Future<void> _onPremiumCta(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.canStartPremiumTrial) {
      final ok = await auth.startPremiumTrial();
      if (!context.mounted) return;
      if (ok) {
        context.push(AppRouter.trialActivation);
        return;
      }
      final msg = auth.errorMessage ?? 'Không kích hoạt được dùng thử.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (auth.user?.isPremium == true) {
      context.push(AppRouter.trialActivation);
      return;
    }
    context.push(AppRouter.subscription);
  }

  static const List<String> _features = [
    'Up to 3 AI menu refreshes per week',
    'Advanced nutrition tracking & insights',
    'Expanded recipe library (250+ dishes)',
    'Smart shopping lists with auto-sync',
    'Ad-free experience',
    'Priority customer support',
  ];

  // Comparison rows
  static const List<CompRow> _compRows = [
    CompRow('AI menu refresh', '1/week', '3/week'),
    CompRow('AI meal plan duration', '3 days', '7 days'),
    CompRow('Meal swap', '2/week', '5/week'),
    CompRow('Calorie tracking', 'Basic', 'Advanced'),
    CompRow('Ads', 'Yes', 'No'),
    CompRow('Diet personalization', 'Limited', 'Full'),
    CompRow('Recipe collections', '100+', '250+'),
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
                      onPressed: () => _onPremiumCta(context),
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
