/// Deep-link redirect used by Supabase OAuth (PKCE).
///
/// Must match:
/// - Supabase Dashboard → Authentication → URL Configuration → Redirect URLs
/// - Android intent-filter + iOS CFBundleURLTypes (scheme = [scheme], host = login-callback)
class OAuthConfig {
  OAuthConfig._();

  static const String scheme = 'com.example.cravvy_cooking_app';
  static const String host = 'login-callback';

  /// e.g. `com.example.cravvy_cooking_app://login-callback`
  static const String redirectUrl = '$scheme://$host';
}
