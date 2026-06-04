import 'package:cravvy_cooking_app/core/constants/oauth_config.dart';

/// Maps Supabase / OAuth error messages to Vietnamese user-facing text.
String mapOAuthAuthError(String message) {
  final m = message.toLowerCase();

  if ((m.contains('not enabled') && m.contains('provider')) ||
      m.contains('unsupported provider') ||
      (m.contains('validation_failed') && m.contains('provider'))) {
    return 'Nhà cung cấp đăng nhập chưa được bật trên Supabase. '
        'Vui lòng bật Google/Apple trong Authentication → Providers.';
  }
  if (m.contains('redirect_uri_mismatch') ||
      m.contains('redirect url') && m.contains('not allowed')) {
    return 'URL chuyển hướng chưa khớp. Thêm ${OAuthConfig.redirectUrl} '
        'vào Supabase → Redirect URLs.';
  }
  if (m.contains('user cancelled') || m.contains('access_denied')) {
    return 'Bạn đã hủy đăng nhập.';
  }
  if (m.contains('invalid login credentials') ||
      m.contains('invalid email or password')) {
    return 'Email hoặc mật khẩu không đúng';
  }
  if (m.contains('email rate limit exceeded')) {
    return 'Gửi quá nhiều lần. Vui lòng thử lại sau.';
  }
  return message;
}
