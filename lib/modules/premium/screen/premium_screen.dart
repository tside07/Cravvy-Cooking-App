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
import 'package:easy_localization/easy_localization.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isAnnual = true;

  static const int _annualPriceVND = 999000;
  static const int _monthlyPriceVND = 149000;
  static const int _annualMonthly = 83250;
  static const int _annualSavings = 789000;
  static const int _savePct = 44;

  Future<void> _onPremiumCta(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.canStartPremiumTrial) {
      final ok = await auth.startPremiumTrial();
      if (!context.mounted) return;
      if (ok) {
        context.push(AppRouter.trialActivation);
        return;
      }
      final msg = auth.errorMessage ?? 'subscription.trial_failed'.tr();
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

  List<String> _features() => [
    'premium.feat.1'.tr(),
    'premium.feat.2'.tr(),
    'premium.feat.3'.tr(),
    'premium.feat.4'.tr(),
    'premium.feat.5'.tr(),
    'premium.feat.6'.tr(),
  ];

  List<CompRow> _compRows() => [
    CompRow(
      'subscription.table.row_ai_suggestions'.tr(),
      'subscription.table.val_1_refresh_week'.tr(),
      'subscription.table.val_2_refresh_week'.tr(),
    ),
    CompRow(
      'subscription.table.row_meal_plan'.tr(),
      'subscription.table.val_3_days'.tr(),
      'subscription.table.val_7_days'.tr(),
    ),
    CompRow(
      'subscription.table.row_meal_swap'.tr(),
      'subscription.table.val_2_per_week'.tr(),
      'subscription.table.val_5_per_week'.tr(),
    ),
    CompRow(
      'subscription.table.row_recipe'.tr(),
      'subscription.table.val_100_plus'.tr(),
      'subscription.table.val_500_plus'.tr(),
    ),
    CompRow(
      'subscription.table.row_shopping'.tr(),
      'subscription.table.val_basic'.tr(),
      'subscription.table.val_advanced'.tr(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return Scaffold(
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
                    PremiumFeaturesCardWidget(features: _features()),
                    AppGap.h20,
                    PremiumComparisonTableWidget(rows: _compRows()),
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
                      'premium.description'.tr(),
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
