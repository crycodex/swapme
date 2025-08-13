import 'package:flutter/material.dart';

class AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Animation<double> animation;
  final Animation<double>? scaleAnimation;
  final Animation<double>? bounceAnimation;

  const AnimatedIcon({
    super.key,
    required this.icon,
    required this.size,
    this.color,
    required this.animation,
    this.scaleAnimation,
    this.bounceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation?.value ?? 1.0,
          child: Transform.translate(
            offset: bounceAnimation != null
                ? Offset(0, -bounceAnimation!.value * 10)
                : Offset.zero,
            child: Opacity(
              opacity: animation.value.clamp(0.0, 1.0),
              child: Icon(icon, size: size, color: color),
            ),
          ),
        );
      },
    );
  }
}

class BouncingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Duration bounceDuration;
  final double bounceHeight;

  const BouncingIcon({
    super.key,
    required this.icon,
    required this.size,
    this.color,
    this.bounceDuration = const Duration(milliseconds: 1000),
    this.bounceHeight = 10.0,
  });

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.bounceDuration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value * widget.bounceHeight),
          child: Icon(widget.icon, size: widget.size, color: widget.color),
        );
      },
    );
  }
}

class CustomPaintIcon extends StatelessWidget {
  final CustomPainter painter;
  final double size;
  final Animation<double>? animation;

  const CustomPaintIcon({
    super.key,
    required this.painter,
    required this.size,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Opacity(
            opacity: animation!.value.clamp(0.0, 1.0),
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(painter: painter),
            ),
          );
        },
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: painter),
      );
    }
  }
}
