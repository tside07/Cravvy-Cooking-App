import 'package:cravvy_cooking_app/core/utils/auth_oauth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapOAuthAuthError', () {
    test('maps disabled provider to setup hint key', () {
      expect(
        mapOAuthAuthError('Provider google is not enabled for this project'),
        'auth.err_oauth_provider_disabled',
      );
    });

    test('maps redirect mismatch to redirect key', () {
      expect(
        mapOAuthAuthError('redirect_uri_mismatch'),
        'auth.err_oauth_redirect',
      );
    });

    test('maps user cancelled', () {
      expect(
        mapOAuthAuthError('User cancelled the login'),
        'auth.err_oauth_user_cancelled',
      );
    });

    test('passes through unknown messages', () {
      const raw = 'Something unexpected';
      expect(mapOAuthAuthError(raw), raw);
    });
  });
}
