import 'package:cravvy_cooking_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animated bouncing dot used on the splash screen.
class LoadingDot extends StatefulWidget {
  const LoadingDot({super.key, required this.delay});

  final int delay;

  @override
  State<LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      // Respect reduced-motion: keep the dot static instead of looping.
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 1.0;
      } else {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: FadeTransition(
      opacity: _anim,
      child: const SizedBox.square(
        dimension: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
