enum AuthOAuthFailure {
  browserNotLaunched,
  cancelledOrTimedOut,
  noProfile,
}

class AuthOAuthException implements Exception {
  const AuthOAuthException(this.failure, {this.details});

  final AuthOAuthFailure failure;
  final String? details;

  @override
  String toString() => 'AuthOAuthException($failure, $details)';
}
