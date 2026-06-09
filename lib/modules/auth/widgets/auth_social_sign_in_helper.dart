import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/core/utils/localized_message.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shared OAuth success navigation; rolls back to [fallbackRoute] on failure.
Future<void> handleSocialSignIn(
  BuildContext context, {
  required Future<bool> Function(AuthProvider auth) signIn,
  String fallbackRoute = AppRouter.welcomeChoice,
}) async {
  final auth = context.read<AuthProvider>();

  try {
    final success = await signIn(auth);
    if (!context.mounted) return;

    if (success) {
      if (auth.user?.onboardingComplete == true) {
        context.go(AppRouter.app);
      } else {
        context.go(AppRouter.setupStep1);
      }
      return;
    }

    _rollbackToAuthHub(context, fallbackRoute);
    _maybeShowOAuthError(context, auth.errorMessage);
  } catch (_) {
    if (!context.mounted) return;
    auth.recoverFromFailedSignIn('auth.oauth_failed');
    _rollbackToAuthHub(context, fallbackRoute);
    _maybeShowOAuthError(context, auth.errorMessage);
  }
}

void _rollbackToAuthHub(BuildContext context, String route) {
  if (GoRouterState.of(context).matchedLocation != route) {
    context.go(route);
  }
}

void _maybeShowOAuthError(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return;
  _showOAuthError(context, message);
}

void _showOAuthError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          localizeMessage(message),
          style: AppTextStyles.s14.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
