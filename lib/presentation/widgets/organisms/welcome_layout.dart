import 'package:flutter/material.dart';
import '../molecules/welcome_content.dart';
import '../atoms/animated_button.dart';

class WelcomeLayout extends StatelessWidget {
  final AnimationController fadeController;
  final AnimationController slideController;
  final AnimationController bounceController;
  final AnimationController scaleController;
  final VoidCallback? onStartPressed;
  final bool isLoading;

  const WelcomeLayout({
    super.key,
    required this.fadeController,
    required this.slideController,
    required this.bounceController,
    required this.scaleController,
    this.onStartPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Animación para el botón
    final buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: Column(
        children: [
          // Contenido principal (fondo púrpura)
          Expanded(
            child: WelcomeContent(
              fadeController: fadeController,
              slideController: slideController,
              bounceController: bounceController,
              scaleController: scaleController,
            ),
          ),

          // Área del botón
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
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
                        onPressed: isLoading ? null : onStartPressed,
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        width: double.infinity,
                        height: 56,
                        borderRadius: BorderRadius.circular(16),
                        isLoading: isLoading,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Texto de ayuda opcional
                if (!isLoading)
                  AnimatedBuilder(
                    animation: buttonAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: buttonAnimation.value.clamp(0.0, 1.0),
                        child: Text(
                          'Toca para comenzar tu experiencia',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
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
        ],
      ),
    );
  }
}
