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
