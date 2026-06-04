import 'package:cravvy_cooking_app/core/routes/app_routers.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shared OAuth success navigation + error snackbar for login/register screens.
Future<void> handleSocialSignIn(
  BuildContext context, {
  required Future<bool> Function(AuthProvider auth) signIn,
}) async {
  final auth = context.read<AuthProvider>();
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

  final error = auth.errorMessage ?? 'Đăng nhập thất bại';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error,
        style: AppTextStyles.s14.copyWith(color: AppColors.white),
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
