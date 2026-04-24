import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/auth_service.dart';
import 'package:cravvy_cooking_app/data/services/supabase_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  // Kiểm tra user đã login chưa khi mở app
  Future<void> _init() async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _user = await AuthService.getProfile(currentUser.id);
      _status = AuthStatus.authenticated;
    } else {
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
        notifyListeners();
        return true;
      }
      _setError('Login failed');
      return false;
    } on Exception catch (e) {
      _setError(e.toString());
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
        notifyListeners();
        return true;
      }
      _setError('Register failed');
      return false;
    } on Exception catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
