import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Fixed shell colors for screens before the main app (unaffected by theme mode).
abstract final class PreAuthTheme {
  static const Color background = Color(0xFF1B262C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color buttonFill = Color(0xFFFFFFFF);
  static const Color buttonText = Color(0xFF1A1A1A);

  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}

/// [Scaffold] wrapper for onboarding, auth, and setup flows.
class PreAuthScaffold extends StatelessWidget {
  const PreAuthScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PreAuthTheme.overlayStyle,
      child: Scaffold(
        backgroundColor: PreAuthTheme.background,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      ),
    );
  }
}

class PreAuthBackButton extends StatelessWidget {
  const PreAuthBackButton({super.key, this.onPressed, this.fallbackRoute});

  final VoidCallback? onPressed;

  /// Used when [context.canPop] is false (e.g. arrived via [GoRouter.go]).
  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => _handleBack(context),
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: PreAuthTheme.textPrimary,
        size: 20,
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (fallbackRoute != null) {
      context.go(fallbackRoute!);
    }
  }
}
