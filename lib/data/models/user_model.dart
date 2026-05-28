class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  // Setup step 2-5 data
  final String? goal;
  final List<String> diets;
  final List<String> avoidFoods;
  final String? cookingTime;
  final String? skillLevel;
  final bool onboardingComplete;
  /// `free` | `premium` | `trial` — see docs/FREEMIUM_SPEC.md
  final String subscriptionTier;
  final DateTime? premiumUntil;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.diets = const [],
    this.avoidFoods = const [],
    this.cookingTime,
    this.skillLevel,
    this.onboardingComplete = false,
    this.subscriptionTier = 'free',
    this.premiumUntil,
  });

  bool get isPremium {
    if (subscriptionTier != 'premium' && subscriptionTier != 'trial') {
      return false;
    }
    if (premiumUntil == null) return true;
    return premiumUntil!.isAfter(DateTime.now());
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      diets: (json['diets'] as List<dynamic>?)?.cast<String>() ?? [],
      avoidFoods:
          (json['avoid_foods'] as List<dynamic>?)?.cast<String>() ?? [],
      cookingTime: json['cooking_time'] as String?,
      skillLevel: json['skill_level'] as String?,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      premiumUntil: json['premium_until'] != null
          ? DateTime.tryParse(json['premium_until'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'goal': goal,
        'diets': diets,
        'avoid_foods': avoidFoods,
        'cooking_time': cookingTime,
        'skill_level': skillLevel,
        'onboarding_complete': onboardingComplete,
        'subscription_tier': subscriptionTier,
        'premium_until': premiumUntil?.toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    List<String>? diets,
    List<String>? avoidFoods,
    String? cookingTime,
    String? skillLevel,
    bool? onboardingComplete,
    String? subscriptionTier,
    DateTime? premiumUntil,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      diets: diets ?? this.diets,
      avoidFoods: avoidFoods ?? this.avoidFoods,
      cookingTime: cookingTime ?? this.cookingTime,
      skillLevel: skillLevel ?? this.skillLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}