import 'package:cravvy_cooking_app/core/constants/oauth_config.dart';
import 'package:cravvy_cooking_app/core/utils/auth_oauth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapOAuthAuthError', () {
    test('maps disabled provider to Vietnamese setup hint', () {
      final msg = mapOAuthAuthError(
        'Provider google is not enabled for this project',
      );
      expect(msg, contains('Supabase'));
      expect(msg, contains('Google'));
    });

    test('maps redirect mismatch with configured redirect URL', () {
      final msg = mapOAuthAuthError('redirect_uri_mismatch');
      expect(msg, contains(OAuthConfig.redirectUrl));
      expect(msg, contains('Redirect URLs'));
    });

    test('maps user cancelled', () {
      expect(
        mapOAuthAuthError('User cancelled the login'),
        'Bạn đã hủy đăng nhập.',
      );
    });

    test('passes through unknown messages', () {
      const raw = 'Something unexpected';
      expect(mapOAuthAuthError(raw), raw);
    });
  });
}
