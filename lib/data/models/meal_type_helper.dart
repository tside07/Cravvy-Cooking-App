// lib/data/models/meal_type_helper.dart
//
// Helper để lấy emoji/color từ mealType string trực tiếp,
// tránh phải convert Recipe → Meal chỉ để dùng MealTypeExt.

import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

abstract final class MealTypeHelper {
  static String emoji(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
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
