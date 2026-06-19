import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/core/constants/oauth_config.dart';

/// Resolves [message] when it is an i18n key (e.g. `auth.err_generic`).
String localizeMessage(String? message, {Map<String, String>? args}) {
  if (message == null || message.isEmpty) return '';
  if (message == 'auth.err_oauth_redirect') {
    return message.tr(namedArgs: {'url': OAuthConfig.redirectUrl});
  }
  if (_looksLikeKey(message)) {
    return message.tr(namedArgs: args);
  }
  return message;
}

bool _looksLikeKey(String message) {
  if (!message.contains('.')) return false;
  if (message.contains(' ')) return false;
  return message.startsWith('auth.') ||
      message.startsWith('settings.') ||
      message.startsWith('recipe.') ||
      message.startsWith('subscription.');
}
