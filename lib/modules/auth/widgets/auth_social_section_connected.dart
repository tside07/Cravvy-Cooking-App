import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_section_widget.dart';
import 'package:cravvy_cooking_app/modules/auth/widgets/auth_social_sign_in_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Social login buttons wired to [AuthProvider] OAuth (Google / Apple).
class AuthSocialSectionConnected extends StatelessWidget {
  const AuthSocialSectionConnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.status == AuthStatus.loading;
        return AuthSocialSectionWidget(
          isEnabled: !isLoading,
          onGoogleTap: () => handleSocialSignIn(
            context,
            signIn: (a) => a.signInWithGoogle(),
          ),
          onAppleTap: () => handleSocialSignIn(
            context,
            signIn: (a) => a.signInWithApple(),
          ),
        );
      },
    );
  }
}
