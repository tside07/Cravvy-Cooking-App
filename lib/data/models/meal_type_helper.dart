// Helper để lấy icon/color từ mealType string — tránh toMeal() trong widgets.

import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

abstract final class MealTypeHelper {
  /// Material rounded icon theo bữa — thay cho emoji, đồng bộ với toàn bộ
  /// icon `_rounded` trong app. Dùng kèm [color] để có sức sống.
  static IconData icon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_twilight_rounded;
      case 'lunch':
        return Icons.wb_sunny_rounded;
      case 'dinner':
        return Icons.nightlight_round;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  static Color color(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return AppColors.breakfast;
      case 'lunch':
        return AppColors.lunch;
      case 'dinner':
        return AppColors.dinner;
      case 'snack':
        return AppColors.snack;
      default:
        return AppColors.primary;
    }
  }

  static Color lightColor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return AppColors.primaryLight;
      case 'lunch':
        return AppColors.secondaryLight;
      case 'dinner':
        return const Color(0xFFEDE9FE);
      case 'snack':
        return AppColors.warningLight;
      default:
        return AppColors.primaryLight;
    }
  }
}
