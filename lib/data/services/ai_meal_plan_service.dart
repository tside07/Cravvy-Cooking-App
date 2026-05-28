import 'package:cravvy_cooking_app/data/services/meal_plan_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

/// Result from `generate-meal-plan` Edge Function.
class AiMealPlanResult {
  const AiMealPlanResult({
    required this.success,
    this.cached = false,
    this.entriesCount,
    this.weekStart,
  });

  final bool success;
  final bool cached;
  final int? entriesCount;
  final String? weekStart;

  factory AiMealPlanResult.fromJson(Map<String, dynamic> json) {
    return AiMealPlanResult(
      success: json['success'] as bool? ?? false,
      cached: json['cached'] as bool? ?? false,
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
  static const _timeout = Duration(seconds: 45);

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
        throw AiMealPlanException(
          data['error'].toString(),
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
