import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Animation<double>? animation;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final Widget? loadingWidget;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.animation,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
    });
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
    });
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
    });
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.colorScheme.primary;
    final effectiveTextColor = widget.textColor ?? theme.colorScheme.onPrimary;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(16.0);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _handleTapDown : null,
            onTapUp: widget.onPressed != null ? _handleTapUp : null,
            onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
            onTap: widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: effectiveBackgroundColor.withOpacity(0.3),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveBackgroundColor.withOpacity(0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: effectiveBorderRadius,
                  child: Container(
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                    child: Center(
                      child: widget.isLoading
                          ? (widget.loadingWidget ??
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      effectiveTextColor,
                                    ),
                                  ),
                                ))
                          : Text(
                              widget.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: effectiveTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulseButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const PulseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.borderRadius,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedButton(
            text: widget.text,
            onPressed: widget.onPressed,
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}
