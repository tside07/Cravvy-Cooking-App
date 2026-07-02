import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cravvy_cooking_app/core/constants/oauth_config.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/auth_oauth_exception.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    // Trigger handle_new_user có thể đã tạo profile nhưng chưa có full_name; cũng
    // có thể chưa kịp tạo (race). Upsert theo id để set chắc chắn dù row đã tồn
    // tại hay chưa — tránh trường hợp .update() không khớp row nào -> tên trống.
    await _client.from('profiles').upsert({
      'id': response.user!.id,
      'full_name': fullName,
      'email': email,
    });

    return await getProfile(response.user!.id);
  }

  static const Duration oauthSessionTimeout = Duration(seconds: 30);

  static _OAuthWaiter? _pendingWaiter;
  static Completer<void>? _cancelCompleter;

  /// Aborts an in-flight OAuth wait (user tapped Cancel or returned to the app).
  static void cancelPendingOAuth() {
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete();
    }
    _cancelCompleter = null;
    _pendingWaiter?.cancelWait(completeWithNull: true);
    _pendingWaiter = null;
  }

  static Future<UserModel?> signInWithGoogle() =>
      signInWithOAuthProvider(OAuthProvider.google);

  static Future<UserModel?> signInWithApple() =>
      signInWithOAuthProvider(OAuthProvider.apple);

  /// Opens provider OAuth in browser; waits for PKCE deep-link session.
  static Future<UserModel?> signInWithOAuthProvider(
    OAuthProvider provider,
  ) async {
    final waiter = _listenForOAuthSignIn();
    _pendingWaiter = waiter;
    _cancelCompleter = Completer<void>();
    final cancelSignal = _cancelCompleter!.future;

    try {
      final launched = await _client.auth.signInWithOAuth(
        provider,
        redirectTo: OAuthConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const AuthOAuthException(AuthOAuthFailure.browserNotLaunched);
      }

      final user = await _waitForOAuthSession(waiter, cancelSignal);
      if (user == null) {
        throw const AuthOAuthException(AuthOAuthFailure.cancelledOrTimedOut);
      }

      final profile = await ensureProfileFromAuthUser(user);
      if (profile == null) {
        throw const AuthOAuthException(AuthOAuthFailure.noProfile);
      }
      return profile;
    } catch (e) {
      try {
        await _client.auth.signOut();
      } catch (signOutErr) {
        if (kDebugMode) {
          debugPrint('OAuth cleanup signOut failed: $signOutErr');
        }
      }
      rethrow;
    } finally {
      _cancelCompleter = null;
      _pendingWaiter = null;
      await waiter.cancelWait();
    }
  }

  static Future<User?> _waitForOAuthSession(
    _OAuthWaiter waiter,
    Future<void> cancelSignal,
  ) async {
    try {
      return await Future.any<User?>([
        waiter.future,
        cancelSignal.then(
          (_) => throw const AuthOAuthException(AuthOAuthFailure.userCancelled),
        ),
      ]).timeout(
        oauthSessionTimeout,
        onTimeout: () {
          throw const AuthOAuthException(AuthOAuthFailure.cancelledOrTimedOut);
        },
      );
    } on AuthOAuthException {
      rethrow;
    }
  }

  static _OAuthWaiter _listenForOAuthSignIn() {
    final completer = Completer<User?>();
    final sub = _client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn &&
          state.session?.user != null &&
          !completer.isCompleted) {
        completer.complete(state.session!.user);
      }
    });
    return _OAuthWaiter(completer, sub);
  }

  /// Creates or updates `profiles` row after OAuth when trigger did not run.
  static Future<UserModel?> ensureProfileFromAuthUser(User user) async {
    final existing = await getProfile(user.id);
    if (existing != null) return existing;

    final meta = user.userMetadata ?? {};
    final fullName = (meta['full_name'] ?? meta['name'] ?? '') as String;
    final email = user.email ?? '';
    final avatarUrl = meta['avatar_url'] ?? meta['picture'];

    final row = <String, dynamic>{
      'id': user.id,
      'email': email,
      if (fullName.isNotEmpty) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    await _client.from('profiles').upsert(row);
    return getProfile(user.id);
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

  /// Kích hoạt gói dùng thử Premium 14 ngày (một lần) qua Edge Function
  /// `start-trial`. Client không còn được ghi trực tiếp `subscription_tier` /
  /// `premium_until` (đã bị trigger DB khoá) — server ghi bằng service_role sau
  /// khi xác thực + kiểm tra điều kiện, rồi ta đọc lại hồ sơ.
  ///
  /// Trả `null` nếu không kích hoạt được (vd: đã dùng trial trước đó -> 409,
  /// hoặc lỗi server). [AuthProvider] map `null` thành thông báo lỗi trial.
  static Future<UserModel?> startPremiumTrial(String userId) async {
    final response = await _client.functions.invoke('start-trial');
    final data = response.data;
    if (data is Map && data['success'] == true) {
      return getProfile(userId);
    }
    return null;
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

class _OAuthWaiter {
  _OAuthWaiter(Completer<User?> completer, this._subscription)
      : _completer = completer,
        future = completer.future;

  final Completer<User?> _completer;
  final Future<User?> future;
  final StreamSubscription<AuthState> _subscription;

  Future<void> cancelWait({bool completeWithNull = false}) async {
    if (completeWithNull && !_completer.isCompleted) {
      _completer.complete(null);
    }
    await _subscription.cancel();
  }
}