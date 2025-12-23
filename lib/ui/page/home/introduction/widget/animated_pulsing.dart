import 'package:flutter/material.dart';

class AnimatedPulsing extends StatefulWidget {
  const AnimatedPulsing({
    super.key,
    this.duration = const Duration(milliseconds: 1000),
    this.child,
  });

  final Duration duration;
  final Widget? child;

  @override
  State<AnimatedPulsing> createState() => _AnimatedPulsingState();
}

class _AnimatedPulsingState extends State<AnimatedPulsing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: Tween(
            begin: 0.3,
            end: 1.0,
          ).evaluate(CurvedAnimation(parent: _controller, curve: Curves.ease)),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
