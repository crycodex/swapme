import 'package:flutter/material.dart';
import '../../../controllers/tutorial/tutorial_controller.dart';

class TutorialStepWidget extends StatefulWidget {
  final TutorialStep step;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const TutorialStepWidget({
    super.key,
    required this.step,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<TutorialStepWidget> createState() => _TutorialStepWidgetState();
}

class _TutorialStepWidgetState extends State<TutorialStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _iconController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono animado
          _buildAnimatedIcon(),

          const SizedBox(height: 40),

          // Título
          _buildTitle(),

          const SizedBox(height: 20),

          // Descripción
          _buildDescription(),

          const SizedBox(height: 40),

          // Ilustración decorativa
          _buildDecoration(),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.step.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: widget.step.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(widget.step.icon, size: 60, color: widget.step.color),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textAnimation.value)),
          child: Opacity(
            opacity: _textAnimation.value,
            child: Text(
              widget.step.title,
              style: widget.theme.textTheme.headlineMedium?.copyWith(
                color: widget.colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textAnimation.value)),
          child: Opacity(
            opacity: _textAnimation.value,
            child: Text(
              widget.step.description,
              style: widget.theme.textTheme.bodyLarge?.copyWith(
                color: widget.colorScheme.onSecondary.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecoration() {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * _iconAnimation.value),
          child: Opacity(
            opacity: 0.3 * _iconAnimation.value,
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.step.color.withValues(alpha: 0.1),
                    widget.step.color.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        );
      },
    );
  }
}
