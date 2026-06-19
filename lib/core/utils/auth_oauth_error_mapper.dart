import 'package:cravvy_cooking_app/core/constants/oauth_config.dart';

/// Maps Supabase / OAuth error messages to i18n keys under `auth.*`.
String mapOAuthAuthError(String message) {
  final m = message.toLowerCase();

  if ((m.contains('not enabled') && m.contains('provider')) ||
      m.contains('unsupported provider') ||
      (m.contains('validation_failed') && m.contains('provider'))) {
    return 'auth.err_oauth_provider_disabled';
  }
  if (m.contains('redirect_uri_mismatch') ||
      (m.contains('redirect url') && m.contains('not allowed'))) {
    return 'auth.err_oauth_redirect';
  }
  if (m.contains('user cancelled') || m.contains('access_denied')) {
    return 'auth.err_oauth_user_cancelled';
  }
  if (m.contains('invalid login credentials') ||
      m.contains('invalid email or password')) {
    return 'auth.err_wrong_credentials';
  }
  if (m.contains('email rate limit exceeded')) {
    return 'auth.err_rate_limit';
  }
  return message;
}

/// Resolves [key] when it needs dynamic args (e.g. redirect URL).
String oauthErrorKeyArgs(String key) {
  if (key == 'auth.err_oauth_redirect') {
    return OAuthConfig.redirectUrl;
  }
  return '';
}
