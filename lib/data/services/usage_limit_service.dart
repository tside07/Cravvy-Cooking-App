import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Weekly usage counters (swap, AI refresh). Requires migration week6.
class UsageLimitService {
  static final _client = SupabaseService.client;
  static const _table = 'user_weekly_usage';

  static DateTime weekStartMonday(DateTime ref) {
    final utc = DateTime.utc(ref.year, ref.month, ref.day);
    final wd = utc.weekday; // 1 = Mon
    return utc.subtract(Duration(days: wd - 1));
  }

  static String _weekStartStr(DateTime ref) {
    final mon = weekStartMonday(ref);
    return '${mon.year}-${mon.month.toString().padLeft(2, '0')}-${mon.day.toString().padLeft(2, '0')}';
  }

  static bool userHasPremium(UserModel? user) {
    if (user == null) return false;
    if (!PlanLimits.isPremiumTier(user.subscriptionTier)) return false;
    final until = user.premiumUntil;
    if (until == null) return true;
    return until.isAfter(DateTime.now());
  }

  static String effectiveTier(UserModel? user) =>
      userHasPremium(user) ? PlanLimits.tierPremium : PlanLimits.tierFree;

  static Future<int> swapCountThisWeek(String userId) async {
    try {
      final row = await _client
          .from(_table)
          .select('swap_count')
          .eq('user_id', userId)
          .eq('week_start', _weekStartStr(DateTime.now()))
          .maybeSingle();
      return (row?['swap_count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> canSwap(String userId, UserModel? user) async {
    final tier = effectiveTier(user);
    final used = await swapCountThisWeek(userId);
    return used < PlanLimits.swapsPerWeek(tier);
  }

  static Future<int> swapsRemaining(String userId, UserModel? user) async {
    final tier = effectiveTier(user);
    final used = await swapCountThisWeek(userId);
    return (PlanLimits.swapsPerWeek(tier) - used).clamp(0, 999);
  }

  static Future<void> recordSwap(String userId) async {
    final week = _weekStartStr(DateTime.now());
    try {
      final existing = await _client
          .from(_table)
          .select('swap_count')
          .eq('user_id', userId)
          .eq('week_start', week)
          .maybeSingle();

      if (existing == null) {
        await _client.from(_table).insert({
          'user_id': userId,
          'week_start': week,
          'swap_count': 1,
          'ai_refresh_count': 0,
        });
      } else {
        final n = (existing['swap_count'] as num?)?.toInt() ?? 0;
        await _client.from(_table).update({
          'swap_count': n + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId).eq('week_start', week);
      }
    } catch (_) {
      // Table missing or RLS — ignore so demo still works
    }
  }

  static Future<int> aiRefreshCountThisWeek(String userId) async {
    try {
      final row = await _client
          .from(_table)
          .select('ai_refresh_count')
          .eq('user_id', userId)
          .eq('week_start', _weekStartStr(DateTime.now()))
          .maybeSingle();
      return (row?['ai_refresh_count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> canAiRefresh(String userId, UserModel? user) async {
    final tier = effectiveTier(user);
    final used = await aiRefreshCountThisWeek(userId);
    return used < PlanLimits.aiRefreshPerWeek(tier);
  }

  static Future<void> recordAiRefresh(String userId) async {
    final week = _weekStartStr(DateTime.now());
    try {
      final existing = await _client
          .from(_table)
          .select('ai_refresh_count')
          .eq('user_id', userId)
          .eq('week_start', week)
          .maybeSingle();

      if (existing == null) {
        await _client.from(_table).insert({
          'user_id': userId,
          'week_start': week,
          'swap_count': 0,
          'ai_refresh_count': 1,
        });
      } else {
        final n = (existing['ai_refresh_count'] as num?)?.toInt() ?? 0;
        await _client.from(_table).update({
          'ai_refresh_count': n + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId).eq('week_start', week);
      }
    } catch (_) {}
  }
}
