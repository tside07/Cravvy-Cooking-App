import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';

class AuthService {
  static final _client = SupabaseService.client;

  static Future<UserModel?> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) return null;

    // TODO: Trigger đã tạo profile, nhưng full_name có thể chưa có — update thêm
    await _client
        .from('profiles')
        .update({'full_name': fullName, 'email': email})
        .eq('id', response.user!.id);

    return await getProfile(response.user!.id);
  }

  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return await getProfile(response.user!.id);
  }

  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  static Future<UserModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); // dùng maybeSingle để không throw nếu chưa có

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  static Future<void> sendPasswordResetOtp(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Future<bool> verifyOtp({
    required String email,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery, // type này cho forgot password OTP
    );
    return response.user != null;
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  static int ageFromBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Updates display fields on `profiles` (edit profile screen).
  static Future<UserModel?> updateDisplayProfile({
    required String userId,
    required String fullName,
    required DateTime birthDate,
    String? email,
  }) async {
    final updates = <String, dynamic>{
      'full_name': fullName.trim(),
      'age': ageFromBirthDate(birthDate),
    };
    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      updates['email'] = trimmedEmail;
    }

    await _client.from('profiles').update(updates).eq('id', userId);
    return getProfile(userId);
  }

  static Future<UserModel?> updateProfileBasicInfo({
    required String userId,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
  }) async {
    await _client.from('profiles').update({
      'age': age,
      'gender': gender.toLowerCase(),
      'height_cm': heightCm,
      'weight_kg': weightKg,
    }).eq('id', userId);

    return await getProfile(userId);
  }

  /// Activates 14-day Premium trial on `profiles` (no payment).
  static Future<UserModel?> startPremiumTrial(String userId) async {
    final until = DateTime.now().add(
      const Duration(days: PlanLimits.premiumTrialDays),
    );
    await _client.from('profiles').update({
      'subscription_tier': PlanLimits.tierTrial,
      'premium_until': until.toUtc().toIso8601String(),
    }).eq('id', userId);

    return getProfile(userId);
  }

  static Future<UserModel?> updateSetupData({
    required String userId,
    String? goal,
    List<String>? diets,
    List<String>? avoidFoods,
    String? cookingTime,
    String? skillLevel,
    bool? onboardingComplete,
  }) async {
    final updates = <String, dynamic>{};
    if (goal != null) updates['goal'] = goal;
    if (diets != null) updates['diets'] = diets;
    if (avoidFoods != null) updates['avoid_foods'] = avoidFoods;
    if (cookingTime != null) updates['cooking_time'] = cookingTime;
    if (skillLevel != null) updates['skill_level'] = skillLevel;
    if (onboardingComplete != null) {
      updates['onboarding_complete'] = onboardingComplete;
    }

    if (updates.isEmpty) return await getProfile(userId);

    await _client.from('profiles').update(updates).eq('id', userId);
    return await getProfile(userId);
  }

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}