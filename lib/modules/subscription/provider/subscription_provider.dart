import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/feature_row.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_highlight.dart';
import 'package:cravvy_cooking_app/modules/subscription/models/subscription_plan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  String _selectedPlanId = 'annual';
  String get selectedPlanId => _selectedPlanId;

  bool get isFreePlan => _selectedPlanId == 'free';

  void selectPlan(String id) {
    if (_selectedPlanId == id) return;
    _selectedPlanId = id;
    notifyListeners();
  }

  /// Build tại runtime để `.tr()` đúng ngôn ngữ hiện tại.
  static List<SubscriptionPlan> plans() => [
    SubscriptionPlan(
      id: 'free',
      name: 'subscription.plan.free_name'.tr(),
      priceLabel: 'subscription.plan.free_price'.tr(),
      priceNote: 'subscription.plan.free_note'.tr(),
    ),
    SubscriptionPlan(
      id: 'monthly',
      name: 'subscription.plan.monthly_name'.tr(),
      priceLabel: 'subscription.plan.monthly_price'.tr(),
      priceNote: 'subscription.plan.monthly_note'.tr(),
    ),
    SubscriptionPlan(
      id: 'annual',
      name: 'subscription.plan.annual_name'.tr(),
      priceLabel: 'subscription.plan.annual_price'.tr(),
      priceNote: 'subscription.plan.annual_note'.tr(),
      badge: 'subscription.plan.annual_badge'.tr(),
      highlight: true,
    ),
  ];

  static List<SubscriptionHighlight> highlights() => [
    SubscriptionHighlight(
      icon: Icons.auto_awesome_outlined,
      color: const Color(0xFFF77C0F),
      title: 'subscription.highlight.ai_chef_title'.tr(),
      desc: 'subscription.highlight.ai_chef_desc'.tr(),
    ),
    SubscriptionHighlight(
      icon: Icons.swap_horiz_rounded,
      color: const Color(0xFF6A8A42),
      title: 'subscription.highlight.swap_title'.tr(),
      desc: 'subscription.highlight.swap_desc'.tr(namedArgs: {
        'n': '${PlanLimits.premiumSwapsPerWeek}',
      }),
    ),
    SubscriptionHighlight(
      icon: Icons.calendar_month_outlined,
      color: const Color(0xFFD97706),
      title: 'subscription.highlight.plan_title'.tr(),
      desc: 'subscription.highlight.plan_desc'.tr(namedArgs: {
        'days': '${PlanLimits.premiumMealPlanVisibleDays}',
      }),
    ),
    SubscriptionHighlight(
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF6B7280),
      title: 'subscription.highlight.recipes_title'.tr(),
      desc: 'subscription.highlight.recipes_desc'.tr(namedArgs: {
        'n': '${PlanLimits.premiumRecipeFetchLimit}',
      }),
    ),
  ];

  static List<FeatureRow> featureRows() => [
    FeatureRow(
      label: 'subscription.table.row_ai_suggestions'.tr(),
      freeVal: 'subscription.table.val_1_refresh_week'.tr(),
      premiumVal: 'subscription.table.val_2_refresh_week'.tr(),
    ),
    FeatureRow(
      label: 'subscription.table.row_meal_plan'.tr(),
      freeVal: 'subscription.table.val_3_days'.tr(),
      premiumVal: 'subscription.table.val_7_days'.tr(),
    ),
    FeatureRow(
      label: 'subscription.table.row_meal_swap'.tr(),
      freeVal: 'subscription.table.val_2_per_week'.tr(),
      premiumVal: 'subscription.table.val_5_per_week'.tr(),
    ),
    FeatureRow(
      label: 'subscription.table.row_recipe'.tr(),
      freeVal: 'subscription.table.val_100_plus'.tr(),
      premiumVal: 'subscription.table.val_500_plus'.tr(),
    ),
    FeatureRow(
      label: 'subscription.table.row_shopping'.tr(),
      freeVal: 'subscription.table.val_basic'.tr(),
      premiumVal: 'subscription.table.val_advanced'.tr(),
    ),
  ];
}
