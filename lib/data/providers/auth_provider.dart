import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cravvy_cooking_app/core/constants/plan_limits.dart';
import 'package:cravvy_cooking_app/core/utils/auth_oauth_error_mapper.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/account_deletion_service.dart';
import 'package:cravvy_cooking_app/data/services/auth_oauth_exception.dart';
import 'package:cravvy_cooking_app/data/services/auth_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/provider/meal_plan_provider.dart';
import 'package:cravvy_cooking_app/modules/shopping_list/provider/shopping_list_provider.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  MealPlanProvider? _mealPlanProvider;
  RecipeProvider? _recipeProvider;
  ShoppingListProvider? _shoppingListProvider;
  bool? _lastRecipeCatalogPremium;
  bool _oauthInProgress = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isOAuthInProgress => _oauthInProgress;

  void linkMealPlanProvider(MealPlanProvider mp) {
    _mealPlanProvider = mp;
    if (_user != null) {
      _mealPlanProvider!.updateFromUser(_user);
    }
  }

  void linkRecipeProvider(RecipeProvider rp) {
    if (identical(_recipeProvider, rp)) return;
    _recipeProvider = rp;
    if (_user != null) {
      _syncRecipeCatalog();
    }
  }

  void linkShoppingListProvider(ShoppingListProvider provider) {
    _shoppingListProvider = provider;
    if (isLoggedIn) {
      _shoppingListProvider!.updateFromUser(_user);
    } else {
      _shoppingListProvider!.updateFromUser(null);
    }
  }

  void _syncUserToProviders() {
    _mealPlanProvider?.updateFromUser(_user);
    _shoppingListProvider?.updateFromUser(_user);
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
    checkTrialExpiry();
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
      _setError('auth.err_wrong_credentials');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('auth.err_generic');
      return false;
    }
  }

  Future<bool> signInWithGoogle() => _signInWithOAuth(AuthService.signInWithGoogle);

  Future<bool> signInWithApple() => _signInWithOAuth(AuthService.signInWithApple);

  /// Clears stuck loading state after OAuth/email failures.
  void recoverFromFailedSignIn([String? message]) {
    _oauthInProgress = false;
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  /// User closed the browser or tapped Cancel — return to auth hub immediately.
  Future<void> cancelOAuthSignIn() async {
    if (!_oauthInProgress) return;
    AuthService.cancelPendingOAuth();
    await _cleanupPartialOAuthSession();
    _oauthInProgress = false;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _signInWithOAuth(
    Future<UserModel?> Function() signIn,
  ) async {
    _oauthInProgress = true;
    _setLoading();
    try {
      _user = await signIn();
      if (_user != null) {
        _status = AuthStatus.authenticated;
        _syncUserToProviders();
        notifyListeners();
        return true;
      }
      await _cleanupPartialOAuthSession();
      _setError('auth.err_login_failed');
      return false;
    } on AuthOAuthException catch (e) {
      await _cleanupPartialOAuthSession();
      if (e.failure == AuthOAuthFailure.userCancelled) {
        _errorMessage = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      _setError(_mapOAuthFailure(e));
      return false;
    } on AuthException catch (e) {
      await _cleanupPartialOAuthSession();
      _setError(mapOAuthAuthError(_mapAuthError(e.message)));
      return false;
    } catch (e) {
      await _cleanupPartialOAuthSession();
      _setError('auth.err_login_failed');
      return false;
    } finally {
      _oauthInProgress = false;
      if (_status == AuthStatus.loading) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    }
  }

  Future<void> _cleanupPartialOAuthSession() async {
    try {
      if (SupabaseService.currentUser != null) {
        await AuthService.logout();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('cleanupPartialOAuthSession failed: $e');
    }
    _user = null;
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
      _setError('auth.err_register_failed');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('auth.err_generic');
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
      _setError('auth.err_otp_send_failed');
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String token}) async {
    _setLoading();
    try {
      final success = await AuthService.verifyOtp(email: email, token: token);
      if (success) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      }
      _setError('auth.err_otp_invalid_expired');
      return false;
    } on AuthException catch (e) {
      _setError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      _setError('auth.err_otp_verify_failed');
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
      _setError('auth.err_reset_failed');
      return false;
    }
  }

  Future<bool> updateDisplayProfile({
    required String fullName,
    required DateTime birthDate,
    String? email,
  }) async {
    if (!isLoggedIn) return false;
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
      _setError('auth.err_profile_update_failed');
      return false;
    }
  }

  Future<bool> updateProfileBasicInfo({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
  }) async {
    if (!isLoggedIn) return false;
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
      _setError('auth.err_info_update_failed');
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
    if (!isLoggedIn) return false;
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
    if (!isLoggedIn) return false;
    try {
      _user = await AuthService.startPremiumTrial(_user!.id);
      if (_user == null) {
        _setError('auth.err_trial_failed');
        return false;
      }
      _trialExpiryHandled = false;
      _status = AuthStatus.authenticated;
      _syncUserToProviders();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('auth.err_trial_migration');
      return false;
    }
  }

  /// Eligible to start the one-time 14-day trial: logged in, currently Free,
  /// and has never been on the trial/premium tier before.
  bool get canStartPremiumTrial {
    if (!isLoggedIn) return false;
    if (_user!.isPremium) return false;
    return _user!.subscriptionTier == PlanLimits.tierFree;
  }

  /// Any logged-in account that isn't currently Premium can pay to upgrade
  /// here — this is the single entry point for activating Premium.
  bool get canUpgradeToPaid => isLoggedIn && _user!.isPremium == false;

  /// This account has already consumed its one-time trial (tier latched to
  /// `trial`). Combined with [canStartPremiumTrial] this enforces "once only".
  bool get trialUsed => _user?.subscriptionTier == PlanLimits.tierTrial;

  /// The 14-day trial has lapsed (tier still `trial` but [UserModel.premiumUntil]
  /// is in the past). Premium access is already gone via [UserModel.isPremium].
  bool get trialExpired {
    final u = _user;
    if (u == null || u.subscriptionTier != PlanLimits.tierTrial) return false;
    final until = u.premiumUntil;
    return until != null && until.isBefore(DateTime.now());
  }

  bool _trialExpiryHandled = false;

  /// Client-side auto-cancel. When the trial lapses we keep the `trial` tier as
  /// the "already used" marker (so it can't be restarted), but re-sync providers
  /// once so any cached Premium features are dropped immediately. Safe to call
  /// repeatedly (e.g. on app resume / when opening the subscription screen);
  /// it only acts on the first detection of expiry. Never call during build.
  void checkTrialExpiry() {
    if (!trialExpired) {
      _trialExpiryHandled = false;
      return;
    }
    if (_trialExpiryHandled) return;
    _trialExpiryHandled = true;
    _syncUserToProviders();
    notifyListeners();
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
    if (!isLoggedIn) {
      _setError('auth.err_delete_login_required');
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
      _setError('settings.delete_failed');
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

  String _mapOAuthFailure(AuthOAuthException e) {
    switch (e.failure) {
      case AuthOAuthFailure.userCancelled:
        return '';
      case AuthOAuthFailure.browserNotLaunched:
        return 'auth.err_oauth_browser';
      case AuthOAuthFailure.cancelledOrTimedOut:
        return 'auth.err_oauth_cancelled_timeout';
      case AuthOAuthFailure.noProfile:
        return 'auth.err_oauth_no_profile';
    }
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') ||
        m.contains('invalid email or password')) {
      return 'auth.err_wrong_credentials';
    }
    if (m.contains('email already registered') ||
        m.contains('user already registered')) {
      return 'auth.err_email_registered';
    }
    if (m.contains('password should be at least')) {
      return 'auth.err_password_min_6';
    }
    if (m.contains('email rate limit exceeded')) {
      return 'auth.err_rate_limit';
    }
    if (m.contains('token has expired') || m.contains('otp expired')) {
      return 'auth.err_otp_expired';
    }
    if (m.contains('invalid otp') || m.contains('token is invalid')) {
      return 'auth.err_otp_invalid';
    }
    return message;
  }

  String _mapDeleteAccountError(String message) {
    final m = message.toLowerCase();
    if (m.contains('unauthorized') || m.contains('missing authorization')) {
      return 'settings.delete_session_expired';
    }
    if (m.contains('server configuration missing')) {
      return 'settings.delete_not_configured';
    }
    if (m.contains('network') || m.contains('timeout')) {
      return 'settings.delete_network';
    }
    return 'settings.delete_failed';
  }
}
