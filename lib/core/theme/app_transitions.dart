import 'package:flutter/material.dart';

class FadeSlideTransition extends PageRouteBuilder {
  final Widget page;
  final Offset beginOffset;

  FadeSlideTransition({
    required this.page,
    this.beginOffset = const Offset(0.0, 0.05),
  }) : super(
         transitionDuration: const Duration(milliseconds: 320),
         reverseTransitionDuration: const Duration(milliseconds: 280),
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOut,
           );
           return FadeTransition(
             opacity: curved,
             child: SlideTransition(
               position: Tween<Offset>(
                 begin: beginOffset,
                 end: Offset.zero,
               ).animate(curved),
               child: child,
             ),
           );
         },
       );
}

// Reusable animated container for stagger effects
class StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final int baseDelayMs;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 80,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: widget.index * widget.baseDelayMs),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
