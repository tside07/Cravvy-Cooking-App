import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sign In')),
      body: const Center(
        child: Text(
          '🔐  Login — Coming Soon',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
