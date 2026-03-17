import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify OTP')),
      body: const Center(
        child: Text(
          '🔑  OTP Verification — Coming Soon',
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
