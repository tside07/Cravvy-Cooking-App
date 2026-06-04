import 'package:cravvy_cooking_app/data/models/user_model.dart';
import 'package:cravvy_cooking_app/data/services/auth_service.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProfileProvider syncFromUser maps Supabase profile fields', () {
    final provider = ProfileProvider();
    provider.syncFromUser(
      const UserModel(
        id: 'u1',
        email: 'chef@cravvy.app',
        fullName: 'Minh Nguyen',
        age: 26,
        heightCm: 172,
        weightKg: 68,
      ),
    );

    expect(provider.name, 'Minh Nguyen');
    expect(provider.email, 'chef@cravvy.app');
    expect(provider.age, 26);
    expect(provider.heightCm, 172);
    expect(provider.weightKg, 68);
    expect(provider.initials, 'MN');
  });

  test('ProfileProvider clears on logout sync', () {
    final provider = ProfileProvider();
    provider.syncFromUser(
      const UserModel(id: 'u1', email: 'a@b.com', fullName: 'A B'),
    );
    provider.updateLocalProfile(
      phone: '+84 900',
      bio: 'Foodie',
      birthDate: DateTime(2000, 5, 1),
    );

    provider.syncFromUser(null);

    expect(provider.name, isEmpty);
    expect(provider.email, isEmpty);
    expect(provider.phone, isEmpty);
    expect(provider.bio, isEmpty);
  });

  test('AuthService.ageFromBirthDate computes years from birth date', () {
    final birthDate = DateTime(DateTime.now().year - 30, 1, 1);
    expect(AuthService.ageFromBirthDate(birthDate), 30);
  });
}
