import 'package:flutter/material.dart';

import 'package:cravvy_cooking_app/core/theme/app_color_scheme_extension.dart';
import 'package:cravvy_cooking_app/core/theme/app_shadows.dart';

/// Press feedback primitive: scales the child to [pressedScale] while held.
///
/// Performance: animates `transform` only (never width/height), wraps the child
/// in a single [AnimatedScale], and is `const`-friendly. Honors reduced-motion
/// (`MediaQuery.disableAnimations`) by collapsing the duration to zero.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 150),
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: reduceMotion ? Duration.zero : widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A tappable card with Soft UI press feedback: scales down and lifts its
/// shadow from [restShadow] to [pressedShadow] while held.
///
/// Surface and border colors are theme-aware (via `context.appColors`),
/// matching `cardBox()`. Wrap in a [RepaintBoundary] at the call site for
/// long lists.
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.color,
    this.radius = 12,
    this.border,
    this.restShadow,
    this.pressedShadow,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 150),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final Border? border;

  /// Defaults to [AppShadows.e1] (brightness-aware).
  final List<BoxShadow>? restShadow;

  /// Shadow while pressed. Defaults to [AppShadows.e2] (brightness-aware).
  final List<BoxShadow>? pressedShadow;

  final double pressedScale;
  final Duration duration;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final appColors = context.appColors;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final rest = widget.restShadow ?? AppShadows.e1Of(brightness);
    final pressed = widget.pressedShadow ?? AppShadows.e2Of(brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: reduceMotion ? Duration.zero : widget.duration,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : widget.duration,
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? appColors.cardSurface,
            borderRadius: BorderRadius.circular(widget.radius),
            border: widget.border ??
                (isDark ? Border.all(color: appColors.borderDivider) : null),
            boxShadow: _pressed ? pressed : rest,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
