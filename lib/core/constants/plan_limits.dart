// Free vs Premium limits — see docs/FREEMIUM_SPEC.md

class PlanLimits {
  PlanLimits._();

  static const String tierFree = 'free';
  static const String tierPremium = 'premium';
  static const String tierTrial = 'trial';

  /// Premium trial length shown in subscription UI.
  static const int premiumTrialDays = 14;

  /// Meal swaps per ISO week (Monday start, UTC-aligned in UsageLimitService).
  static const int freeSwapsPerWeek = 2;
  static const int premiumSwapsPerWeek = 5;

  /// Edge Function `force_refresh` calls per week (excluding first auto-fill).
  static const int freeAiRefreshPerWeek = 1;
  static const int premiumAiRefreshPerWeek = 2;

  /// Min wait between two force_refresh calls (same user).
  static const int aiRefreshCooldownMinutes = 5;

  /// QA/dev only — must be false in production (protects Gemini free-tier quota).
  static const bool bypassAiRefreshLimit = false;

  static const int freeMealPlanVisibleDays = 3;
  static const int premiumMealPlanVisibleDays = 7;

  static const int freeRecipeFetchLimit = 100;
  static const int premiumRecipeFetchLimit = 500;

  /// AI cooking chatbot messages per day (protects Gemini free-tier quota).
  /// Keep in sync with `cooking-chat` Edge Function.
  static const int freeChatDailyLimit = 15;
  static const int premiumChatDailyLimit = 60;

  /// AI "cook from my ingredients" suggestions per day. Counts only REAL Gemini
  /// calls — cache/DB-matched results don't consume the cap. Tuned for Gemini
  /// free tier; keep in sync with `suggest-from-ingredients` Edge Function.
  static const int freeAiSuggestDailyLimit = 5;
  static const int premiumAiSuggestDailyLimit = 15;

  static int aiSuggestDailyLimit(String? tier) =>
      isPremiumTier(tier) ? premiumAiSuggestDailyLimit : freeAiSuggestDailyLimit;

  /// Supabase `recipes.source` values visible to Free users.
  static const List<String> freeRecipeSources = [
    'cravvy_curated_vn',
  ];

  static bool isPremiumTier(String? tier) {
    if (tier == null) return false;
    return tier == tierPremium || tier == tierTrial;
  }

  static int swapsPerWeek(String? tier) =>
      isPremiumTier(tier) ? premiumSwapsPerWeek : freeSwapsPerWeek;

  static int aiRefreshPerWeek(String? tier) =>
      isPremiumTier(tier) ? premiumAiRefreshPerWeek : freeAiRefreshPerWeek;

  static int recipeFetchLimit(String? tier) =>
      isPremiumTier(tier) ? premiumRecipeFetchLimit : freeRecipeFetchLimit;

  static int chatDailyLimit(String? tier) =>
      isPremiumTier(tier) ? premiumChatDailyLimit : freeChatDailyLimit;
}
