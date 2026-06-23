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

  /// Raised card / input fill on the dark shell.
  static const Color surface = Color(0xFF2A3A44);

  /// Subtle divider/border visible on the dark shell.
  static const Color border = Color(0x33FFFFFF);

  /// Hairline highlight on the top edge of soft fields/cards (simulated lift).
  static const Color fieldBorder = Color(0x1FFFFFFF);

  /// Muted icon/text for inactive states on the dark shell.
  static const Color textDisabled = Color(0x66FFFFFF);

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
        body: Stack(
          children: [
            const Positioned.fill(child: _PreAuthGlow()),
            Positioned.fill(child: body),
          ],
        ),
      ),
    );
  }
}

/// Ambient warm glow behind the dark shell — adds depth so flat sections
/// (auth, onboarding) don't read as a sterile flat fill. Sits below content
/// and ignores pointers. Full-bleed photo screens (e.g. landing) simply cover
/// it, so it's safe to apply to every pre-auth screen.
class _PreAuthGlow extends StatelessWidget {
  const _PreAuthGlow();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.72),
            radius: 1.05,
            colors: [Color(0x26FF6B35), Color(0x00FF6B35)],
            stops: [0.0, 0.62],
          ),
        ),
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
