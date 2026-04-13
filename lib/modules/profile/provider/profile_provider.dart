import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  // ── User data ────────────────────────────────────────────────────────────
  String _name = 'Sarah Johnson';
  String _email = 'sarah.johnson@email.com';
  String _phone = '+84 901 234 567';
  String _bio = 'Health-conscious foodie who loves trying new recipes 🌿';
  DateTime _birthDate = DateTime(1999, 3, 15);
  int _heightCm = 170;
  double _weightKg = 70;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get bio => _bio;
  DateTime get birthDate => _birthDate;
  int get heightCm => _heightCm;
  double get weightKg => _weightKg;

  String get initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name[0].toUpperCase() : '?';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    final hm = _heightCm / 100;
    return _weightKg / (hm * hm);
  }

  String get bmiLabel {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  // ── Update ───────────────────────────────────────────────────────────────
  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
    required DateTime birthDate,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _bio = bio;
    _birthDate = birthDate;
    notifyListeners();
  }
}
