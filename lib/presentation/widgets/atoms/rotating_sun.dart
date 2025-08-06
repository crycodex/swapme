import 'package:flutter/material.dart';

class RotatingSun extends StatefulWidget {
  final double size;
  final Animation<double>? animation;
  final Animation<double>? scaleAnimation;

  const RotatingSun({
    super.key,
    required this.size,
    this.animation,
    this.scaleAnimation,
  });

  @override
  State<RotatingSun> createState() => _RotatingSunState();
}

class _RotatingSunState extends State<RotatingSun>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 2 * 3.14159, // 360 grados en radianes
        ).animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.linear),
        );

    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.scaleAnimation?.value ?? 1.0,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: widget.animation?.value.clamp(0.0, 1.0) ?? 1.0,
              child: Image.asset(
                'assets/welcome/sun.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
