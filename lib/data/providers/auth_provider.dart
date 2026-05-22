import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/auth_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  MealPlanProvider? _mealPlanProvider;
  RecipeProvider? _recipeProvider;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  void linkMealPlanProvider(MealPlanProvider mp) {
    _mealPlanProvider = mp;
    if (_user != null) _mealPlanProvider!.updateFromUser(_user);
  }

  void linkRecipeProvider(RecipeProvider rp) {
    _recipeProvider = rp;
    if (_user != null) Future.microtask(rp.loadAll);
  }

  void _syncUserToProviders() {
    _mealPlanProvider?.updateFromUser(_user);
    if (_user != null) {
      Future.microtask(() => _recipeProvider?.loadAll());
    }
  }

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser != null) {
        _user = await AuthService.getProfile(currentUser.id);
        _status = _user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        _syncUserToProviders();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      _user = await AuthService.login(email: email, password: password);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        _syncUserToProviders();
        notifyListeners();
        return true;
      }
      _setError('Email hoặc mật khẩu không đúng');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('Đã có lỗi xảy ra. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _setLoading();
    try {
      _user = await AuthService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (_user != null) {
        _status = AuthStatus.authenticated;
        _syncUserToProviders();
        notifyListeners();
        return true;
      }
      _setError('Đăng ký thất bại. Vui lòng thử lại.');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('Đã có lỗi xảy ra. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> sendPasswordResetOtp(String email) async {
    _setLoading();
    try {
      await AuthService.sendPasswordResetOtp(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('Không thể gửi OTP. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String token}) async {
    _setLoading();
    try {
      final success = await AuthService.verifyOtp(email: email, token: token);
      if (success) {
        _status = AuthStatus.unauthenticated; // vẫn chưa "login" hẳn
        notifyListeners();
        return true;
      }
      _setError('OTP không đúng hoặc đã hết hạn');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('Xác thực thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading();
    try {
      await AuthService.updatePassword(newPassword);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('Cập nhật mật khẩu thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> updateProfileBasicInfo({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
  }) async {
    if (_user == null) return false;
    _setLoading();
    try {
      _user = await AuthService.updateProfileBasicInfo(
        userId: _user!.id,
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
      );
      _status = AuthStatus.authenticated;
      _syncUserToProviders();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Cập nhật thông tin thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> updateSetupData({
    String? goal,
    List<String>? diets,
    List<String>? avoidFoods,
    String? cookingTime,
    String? skillLevel,
    bool? onboardingComplete,
  }) async {
    if (_user == null) return false;
    try {
      _user = await AuthService.updateSetupData(
        userId: _user!.id,
        goal: goal,
        diets: diets,
        avoidFoods: avoidFoods,
        cookingTime: cookingTime,
        skillLevel: skillLevel,
        onboardingComplete: onboardingComplete,
      );
      _syncUserToProviders();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _syncUserToProviders();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = isLoggedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') ||
        m.contains('invalid email or password')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (m.contains('email already registered') ||
        m.contains('user already registered')) {
      return 'Email này đã được đăng ký';
    }
    if (m.contains('password should be at least')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (m.contains('email rate limit exceeded')) {
      return 'Gửi quá nhiều lần. Vui lòng thử lại sau.';
    }
    if (m.contains('token has expired') || m.contains('otp expired')) {
      return 'OTP đã hết hạn. Vui lòng gửi lại.';
    }
    if (m.contains('invalid otp') || m.contains('token is invalid')) {
      return 'OTP không đúng';
    }
    return message;
  }
}
