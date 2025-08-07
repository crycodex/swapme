import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Animation<double> animation;
  final Animation<double>? slideAnimation;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? padding;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    required this.animation,
    this.slideAnimation,
    this.textAlign = TextAlign.left,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: slideAnimation != null
              ? Offset(0, (1 - slideAnimation!.value) * 50)
              : Offset.zero,
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Text(text, style: style, textAlign: textAlign),
            ),
          ),
        );
      },
    );
  }
}

class StaggeredAnimatedText extends StatelessWidget {
  final List<String> texts;
  final List<TextStyle> styles;
  final AnimationController controller;
  final Duration staggerDelay;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? padding;

  const StaggeredAnimatedText({
    super.key,
    required this.texts,
    required this.styles,
    required this.controller,
    this.staggerDelay = const Duration(milliseconds: 200),
    this.textAlign = TextAlign.left,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(texts.length, (index) {
        final delay = index * staggerDelay.inMilliseconds;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay / controller.duration!.inMilliseconds,
              (delay + 800) / controller.duration!.inMilliseconds,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return AnimatedText(
          text: texts[index],
          style: styles[index],
          animation: animation,
          textAlign: textAlign,
          padding: padding,
        );
      }),
    );
  }
}

class CascadeAnimatedText extends StatefulWidget {
  final List<String> texts;
  final List<TextStyle> styles;
  final Duration cascadeDuration;
  final Duration pauseDuration;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? padding;

  const CascadeAnimatedText({
    super.key,
    required this.texts,
    required this.styles,
    this.cascadeDuration = const Duration(milliseconds: 2000),
    this.pauseDuration = const Duration(milliseconds: 1000),
    this.textAlign = TextAlign.left,
    this.padding,
  });

  @override
  State<CascadeAnimatedText> createState() => _CascadeAnimatedTextState();
}

class _CascadeAnimatedTextState extends State<CascadeAnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _cascadeController;
  late AnimationController _pauseController;

  @override
  void initState() {
    super.initState();

    // Controlador para la animación de cascada
    _cascadeController = AnimationController(
      duration: widget.cascadeDuration,
      vsync: this,
    );

    // Controlador para la pausa entre repeticiones
    _pauseController = AnimationController(
      duration: widget.pauseDuration,
      vsync: this,
    );



    _startCascadeAnimation();
  }

  void _startCascadeAnimation() async {
    while (mounted) {
      // Iniciar animación de cascada
      await _cascadeController.forward();

      // Pausa antes de repetir
      await _pauseController.forward();

      // Reiniciar para la siguiente repetición
      _cascadeController.reset();
      _pauseController.reset();
    }
  }

  @override
  void dispose() {
    _cascadeController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.texts.length, (index) {
        final delay = index * 200; // 200ms entre cada texto
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _cascadeController,
            curve: Interval(
              delay / widget.cascadeDuration.inMilliseconds,
              (delay + 600) / widget.cascadeDuration.inMilliseconds,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - animation.value) * 50),
              child: Opacity(
                opacity: animation.value.clamp(0.0, 1.0),
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: Text(
                    widget.texts[index],
                    style: widget.styles[index],
                    textAlign: widget.textAlign,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
