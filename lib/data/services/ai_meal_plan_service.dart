import 'package:cravvy_cooking_app/data/services/meal_plan_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Result from `generate-meal-plan` Edge Function.
class AiMealPlanResult {
  const AiMealPlanResult({
    required this.success,
    this.cached = false,
    this.aiGenerated,
    this.recipesChanged,
    this.entriesCount,
    this.weekStart,
  });

  final bool success;
  final bool cached;
  final bool? aiGenerated;
  final int? recipesChanged;
  final int? entriesCount;
  final String? weekStart;

  factory AiMealPlanResult.fromJson(Map<String, dynamic> json) {
    return AiMealPlanResult(
      success: json['success'] as bool? ?? false,
      cached: json['cached'] as bool? ?? false,
      aiGenerated: json['ai_generated'] as bool?,
      recipesChanged: (json['recipes_changed'] as num?)?.toInt(),
      entriesCount: (json['entries_count'] as num?)?.toInt(),
      weekStart: json['week_start'] as String?,
    );
  }
}

/// Typed failure when Edge Function / Gemini path fails.
class AiMealPlanException implements Exception {
  AiMealPlanException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AiMealPlanException($statusCode): $message';
}

/// Invokes Supabase Edge Function `generate-meal-plan` (Gemini on server).
class AiMealPlanService {
  static const _functionName = 'generate-meal-plan';
  static const _timeout = Duration(seconds: 90);

  /// Generate (or return cached) 7-day plan for [weekStart] Monday.
  static Future<AiMealPlanResult> generateWeek({
    required DateTime weekStart,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await SupabaseService.client.functions
          .invoke(
            _functionName,
            body: {
              'week_start': MealPlanService.dateStr(weekStart),
              'force_refresh': forceRefresh,
            },
          )
          .timeout(_timeout);

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw AiMealPlanException(
          'Invalid response from generate-meal-plan',
          statusCode: response.status,
        );
      }

      if (data['error'] != null) {
        final err = data['error'].toString();
        if (err == 'cooldown') {
          final retry = (data['retry_after_seconds'] as num?)?.toInt();
          throw AiMealPlanException(
            retry != null
                ? 'cooldown:$retry'
                : 'cooldown',
            statusCode: response.status,
          );
        }
        throw AiMealPlanException(
          err,
          statusCode: response.status,
        );
      }

      final result = AiMealPlanResult.fromJson(data);
      if (!result.success) {
        throw AiMealPlanException(
          'Meal plan generation failed',
          statusCode: response.status,
        );
      }
      return result;
    } on AiMealPlanException {
      rethrow;
    } catch (e) {
      throw AiMealPlanException(e.toString());
    }
  }
}
