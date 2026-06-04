import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/account_deletion_service.dart';
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
  bool? _lastRecipeCatalogPremium;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  void linkMealPlanProvider(MealPlanProvider mp) {
    _mealPlanProvider = mp;
    if (_user != null) _mealPlanProvider!.updateFromUser(_user);
  }

  void linkRecipeProvider(RecipeProvider rp) {
    if (identical(_recipeProvider, rp)) return;
    _recipeProvider = rp;
    if (_user != null) _syncRecipeCatalog();
  }

  void _syncUserToProviders() {
    _mealPlanProvider?.updateFromUser(_user);
    _syncRecipeCatalog();
  }

  void _syncRecipeCatalog() {
    if (_user == null || _recipeProvider == null) return;
    _recipeProvider!.updateFromUser(_user);
    final isPremium = _user!.isPremium;
    final shouldForceReload = _lastRecipeCatalogPremium != isPremium;
    _lastRecipeCatalogPremium = isPremium;
    Future.microtask(
      () => _recipeProvider!.loadAll(forceReload: shouldForceReload),
    );
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

  Future<bool> updateDisplayProfile({
    required String fullName,
    required DateTime birthDate,
    String? email,
  }) async {
    if (_user == null) return false;
    _setLoading();
    try {
      _user = await AuthService.updateDisplayProfile(
        userId: _user!.id,
        fullName: fullName,
        birthDate: birthDate,
        email: email,
      );
      _status = AuthStatus.authenticated;
      _syncUserToProviders();
      notifyListeners();
      return _user != null;
    } catch (e) {
      _setError('Cập nhật hồ sơ thất bại. Vui lòng thử lại.');
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

  /// Starts 14-day trial; refreshes meal plan & recipe catalog for Premium access.
  Future<bool> startPremiumTrial() async {
    if (_user == null) return false;
    try {
      _user = await AuthService.startPremiumTrial(_user!.id);
      if (_user == null) {
        _setError('Không kích hoạt được dùng thử. Kiểm tra kết nối.');
        return false;
      }
      _status = AuthStatus.authenticated;
      _syncUserToProviders();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(
        'Không lưu được gói dùng thử. Chạy migration Tuần 6 trên Supabase.',
      );
      return false;
    }
  }

  bool get canStartPremiumTrial {
    if (_user == null) return false;
    if (_user!.isPremium) return false;
    return _user!.subscriptionTier == PlanLimits.tierFree;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _syncUserToProviders();
    notifyListeners();
  }

  /// Permanently deletes account via Edge Function, then clears local session.
  Future<bool> deleteAccount() async {
    if (_user == null) {
      _setError('Bạn cần đăng nhập để xóa tài khoản.');
      return false;
    }
    _setLoading();
    try {
      await AccountDeletionService.deleteAccount();
      await AuthService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _syncUserToProviders();
      notifyListeners();
      return true;
    } on AccountDeletionException catch (e) {
      _setError(_mapDeleteAccountError(e.message));
      return false;
    } catch (_) {
      _setError(
        'Không thể xóa tài khoản. Kiểm tra kết nối hoặc thử lại sau.',
      );
      return false;
    }
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

  String _mapDeleteAccountError(String message) {
    final m = message.toLowerCase();
    if (m.contains('unauthorized') || m.contains('missing authorization')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    if (m.contains('server configuration missing')) {
      return 'Máy chủ chưa cấu hình xóa tài khoản. Liên hệ quản trị viên.';
    }
    if (m.contains('network') || m.contains('timeout')) {
      return 'Mất kết nối. Vui lòng thử lại.';
    }
    return 'Không thể xóa tài khoản: $message';
  }
}
