class NutritionTarget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const NutritionTarget({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  // Fallback mặc định khi chưa có đủ thông tin profile
  static const defaultTarget = NutritionTarget(
    calories: 2000,
    protein: 130,
    carbs: 200,
    fat: 65,
  );
}

class NutritionCalculator {
  /// Tính target từ profile user.
  /// Trả về [NutritionTarget.defaultTarget] nếu thiếu thông tin.
  static NutritionTarget calculate({
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? goal, // 'lose-weight' | 'build-muscle' | 'maintain' | 'health'
  }) {
    // Nếu thiếu bất kỳ field nào cần thiết → dùng default
    if (age == null || weightKg == null || heightCm == null) {
      return _adjustForGoal(NutritionTarget.defaultTarget, goal);
    }

    // ── Bước 1: BMR theo Mifflin-St Jeor ─────────────────────────────────
    // Nam:    BMR = 10W + 6.25H - 5A + 5
    // Nữ:     BMR = 10W + 6.25H - 5A - 161
    // Other:  lấy trung bình
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else if (gender == 'female') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    } else {
      final male = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
      final female = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
      bmr = (male + female) / 2;
    }

    // ── Bước 2: TDEE = BMR × Activity Factor ─────────────────────────────
    // App không hỏi activity level → dùng "lightly active" (1.375) làm default
    final tdee = bmr * 1.375;

    // ── Bước 3: Điều chỉnh theo goal ─────────────────────────────────────
    int targetCalories;
    switch (goal) {
      case 'lose-weight':
        targetCalories = (tdee - 400).round(); // deficit 400 kcal — an toàn
        break;
      case 'build-muscle':
        targetCalories = (tdee + 300).round(); // surplus 300 kcal
        break;
      case 'maintain':
      case 'health':
      default:
        targetCalories = tdee.round();
    }

    // Clamp để không quá thấp hoặc cao vô lý
    targetCalories = targetCalories.clamp(1200, 4000);

    // ── Bước 4: Macros ────────────────────────────────────────────────────
    // Phân bổ theo goal:
    //   lose-weight:   Protein 35% | Carbs 35% | Fat 30%
    //   build-muscle:  Protein 35% | Carbs 45% | Fat 20%
    //   default:       Protein 25% | Carbs 50% | Fat 25%
    int protein, carbs, fat;

    switch (goal) {
      case 'lose-weight':
        protein = ((targetCalories * 0.35) / 4).round();
        carbs = ((targetCalories * 0.35) / 4).round();
        fat = ((targetCalories * 0.30) / 9).round();
        break;
      case 'build-muscle':
        protein = ((targetCalories * 0.35) / 4).round();
        carbs = ((targetCalories * 0.45) / 4).round();
        fat = ((targetCalories * 0.20) / 9).round();
        break;
      default:
        protein = ((targetCalories * 0.25) / 4).round();
        carbs = ((targetCalories * 0.50) / 4).round();
        fat = ((targetCalories * 0.25) / 9).round();
    }

    return NutritionTarget(
      calories: targetCalories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  // Điều chỉnh default target theo goal (khi thiếu height/weight/age)
  static NutritionTarget _adjustForGoal(NutritionTarget base, String? goal) {
    switch (goal) {
      case 'lose-weight':
        return NutritionTarget(
          calories: 1700,
          protein: 140,
          carbs: 150,
          fat: 55,
        );
      case 'build-muscle':
        return NutritionTarget(
          calories: 2400,
          protein: 180,
          carbs: 270,
          fat: 65,
        );
      default:
        return base;
    }
  }
}
