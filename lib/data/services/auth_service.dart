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

    await _client
        .from('profiles')
        .update({'full_name': fullName})
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
        .single();

    return UserModel.fromJson(data);
  }

  static Future<void> forgotPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}
