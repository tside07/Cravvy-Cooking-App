import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:flutter/foundation.dart';

/// UI profile state synced from [UserModel] via [AuthProvider].
/// Phone and bio are local-only until the profiles schema adds those columns.
class ProfileProvider extends ChangeNotifier {
  static const String _guestName = '';
  static const String _guestEmail = '';

  String _name = _guestName;
  String _email = _guestEmail;
  String _phone = '';
  String _bio = '';
  DateTime? _birthDate;
  int _heightCm = 0;
  double _weightKg = 0;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get bio => _bio;
  DateTime get birthDate =>
      _birthDate ?? DateTime(DateTime.now().year - 25, 1, 1);
  int get heightCm => _heightCm;
  double get weightKg => _weightKg;

  String get initials {
    final trimmed = _name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  int get age {
    final bd = _birthDate;
    if (bd == null) return 0;
    final now = DateTime.now();
    var age = now.year - bd.year;
    if (now.month < bd.month ||
        (now.month == bd.month && now.day < bd.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    if (_heightCm <= 0) return 0;
    final hm = _heightCm / 100;
    return _weightKg / (hm * hm);
  }

  String get bmiLabel {
    final b = bmi;
    if (b <= 0) return '—';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Called when [AuthProvider] user changes (login, profile save, logout).
  void syncFromUser(UserModel? user) {
    if (user == null) {
      _clear();
      notifyListeners();
      return;
    }

    _name = (user.fullName?.trim().isNotEmpty ?? false)
        ? user.fullName!.trim()
        : user.email.split('@').first;
    _email = user.email;
    if (user.heightCm != null && user.heightCm! > 0) {
      _heightCm = user.heightCm!.round();
    }
    if (user.weightKg != null && user.weightKg! > 0) {
      _weightKg = user.weightKg!;
    }
    if (user.age != null && user.age! > 0) {
      _birthDate = DateTime(DateTime.now().year - user.age!, 1, 1);
    }
    notifyListeners();
  }

  /// Persists phone/bio locally; name/age/email come from Supabase on save.
  void updateLocalProfile({
    required String phone,
    required String bio,
    required DateTime birthDate,
  }) {
    _phone = phone;
    _bio = bio;
    _birthDate = birthDate;
    notifyListeners();
  }

  void _clear() {
    _name = _guestName;
    _email = _guestEmail;
    _phone = '';
    _bio = '';
    _birthDate = null;
    _heightCm = 0;
    _weightKg = 0;
  }
}
