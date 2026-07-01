import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

/// The Cravvy assistants surfaced in the chat menu drawer. Each maps to the
/// same `cooking-chat` backend; the only behavioural difference today is
/// whether the active week plan is sent as context ([includeWeekPlan]).
enum ChatAssistant {
  aiChef,
  mealPlanner,
  nutritionCoach,
  pantryHelper;

  /// Stable identifier used for persistence (never localized).
  String get id {
    switch (this) {
      case ChatAssistant.aiChef:
        return 'ai_chef';
      case ChatAssistant.mealPlanner:
        return 'meal_planner';
      case ChatAssistant.nutritionCoach:
        return 'nutrition_coach';
      case ChatAssistant.pantryHelper:
        return 'pantry_helper';
    }
  }

  static ChatAssistant fromId(String? id) {
    return ChatAssistant.values.firstWhere(
      (a) => a.id == id,
      orElse: () => ChatAssistant.aiChef,
    );
  }

  /// Leading glyph for menu rows and the header identity.
  IconData get icon {
    switch (this) {
      case ChatAssistant.aiChef:
        return Icons.restaurant_menu_rounded;
      case ChatAssistant.mealPlanner:
        return Icons.calendar_month_rounded;
      case ChatAssistant.nutritionCoach:
        return Icons.monitor_heart_outlined;
      case ChatAssistant.pantryHelper:
        return Icons.kitchen_outlined;
    }
  }

  /// Sends the user's saved week plan as context (Meal Planner only).
  bool get includeWeekPlan => this == ChatAssistant.mealPlanner;

  String get nameKey => 'chat.assistant.$id.name';
  String get taglineKey => 'chat.assistant.$id.tagline';

  /// Quick-prompt chip labels shown above the composer for this assistant.
  List<String> get suggestionKeys {
    switch (this) {
      case ChatAssistant.aiChef:
        return const [
          'chat.suggestions.lose_weight',
          'chat.suggestions.high_protein_dinner',
          'chat.suggestions.quick_breakfast',
          'chat.suggestions.use_what_i_have',
        ];
      case ChatAssistant.mealPlanner:
        return const [
          'chat.suggestions.plan_my_week',
          'chat.suggestions.balanced_dinners',
          'chat.suggestions.calorie_target_day',
          'chat.suggestions.build_shopping_list',
        ];
      case ChatAssistant.nutritionCoach:
        return const [
          'chat.suggestions.hit_protein_goal',
          'chat.suggestions.cut_sugar',
          'chat.suggestions.pre_workout_meal',
          'chat.suggestions.explain_my_macros',
        ];
      case ChatAssistant.pantryHelper:
        return const [
          'chat.suggestions.use_what_i_have',
          'chat.suggestions.no_waste_dinner',
          'chat.suggestions.substitute_ingredient',
          'chat.suggestions.three_ingredients',
        ];
    }
  }
}
