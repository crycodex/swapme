import 'package:flutter/material.dart';
import '../molecules/welcome_content.dart';
import '../atoms/animated_button.dart';
import 'package:glossy/glossy.dart';

class WelcomeLayout extends StatefulWidget {
  final VoidCallback? onStartPressed;
  final bool isLoading;

  const WelcomeLayout({super.key, this.onStartPressed, this.isLoading = false});

  @override
  State<WelcomeLayout> createState() => _WelcomeLayoutState();
}

class _WelcomeLayoutState extends State<WelcomeLayout>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _bounceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Animación para el botón
    final buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: Column(
        children: [
          // Contenido principal (fondo púrpura)
          Expanded(
            child: WelcomeContent(
              fadeController: _fadeController,
              slideController: _slideController,
              bounceController: _bounceController,
              scaleController: _scaleController,
            ),
          ),

          // Área del botón con efecto glassmorphism
          GlossyContainer(
            width: double.infinity,
            height: 150, // Altura fija para el contenedor glossy
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón "Empezar" animado
                  AnimatedBuilder(
                    animation: buttonAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: buttonAnimation.value,
                        child: AnimatedButton(
                          text: 'Empezar',
                          onPressed: widget.isLoading
                              ? null
                              : widget.onStartPressed,
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          width: double.infinity,
                          height: 56,
                          borderRadius: BorderRadius.circular(16),
                          isLoading: widget.isLoading,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Texto de ayuda opcional
                  if (!widget.isLoading)
                    AnimatedBuilder(
                      animation: buttonAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: buttonAnimation.value.clamp(0.0, 1.0),
                          child: Text(
                            'Toca para comenzar tu experiencia',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outlineVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
