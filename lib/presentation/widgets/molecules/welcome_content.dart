import 'package:flutter/material.dart';
import '../atoms/animated_text.dart';
import '../atoms/rotating_sun.dart';
import '../atoms/breathing_cloth.dart';

class WelcomeContent extends StatelessWidget {
  final AnimationController fadeController;
  final AnimationController slideController;
  final AnimationController bounceController;
  final AnimationController scaleController;

  const WelcomeContent({
    super.key,
    required this.fadeController,
    required this.slideController,
    required this.bounceController,
    required this.scaleController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic),
    );

    final bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeOutCubic),
    );

    final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeOutCubic),
    );

    return Stack(
      children: [
        // Fondo púrpura principal
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: colorScheme.secondary),
        ),

        // Contenido principal
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol rotatorio personalizado en el lado derecho
                Align(
                  alignment: Alignment.topRight,
                  child: RotatingSun(
                    size: 100,
                    animation: bounceAnimation,
                    scaleAnimation: scaleAnimation,
                  ),
                ),

                // Textos principales con animación de cascada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Intercambia" y "Descubre" con animación de cascada
                      CascadeAnimatedText(
                        texts: ['Intercambia,', 'Descubre,'],
                        styles: [
                          theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                          theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                        ],
                        cascadeDuration: const Duration(milliseconds: 2500),
                        pauseDuration: const Duration(milliseconds: 1500),
                        padding: const EdgeInsets.only(bottom: 2.0),
                      ),

                      // "Estrena" con fondo especial (cinta)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CascadeAnimatedText(
                          texts: ['Estrena'],
                          styles: [
                            theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ) ??
                                TextStyle(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                          ],
                          cascadeDuration: const Duration(milliseconds: 2500),
                          pauseDuration: const Duration(milliseconds: 1500),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contenedor con camiseta y texto lado a lado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Camiseta con animación de respiración (lado izquierdo)
                          Transform.rotate(
                            angle: -0.2, // Rotar un poco el buzo
                            child: BreathingCloth(
                              size: 135,
                              animation: bounceAnimation,
                              scaleAnimation: scaleAnimation,
                            ),
                          ),

                          // Textos "Dale una nueva vida a tu clóset" (lado derecho)
                          Expanded(
                            child: CascadeAnimatedText(
                              texts: [
                                'Dale',
                                'una nueva',
                                'vida a tu',
                                'clóset',
                              ],
                              styles: [
                                theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ),
                                theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ),
                                theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ),
                                theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.pink[200],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ) ??
                                    TextStyle(
                                      color: Colors.pink[200],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ),
                              ],
                              cascadeDuration: const Duration(
                                milliseconds: 2000,
                              ),
                              pauseDuration: const Duration(milliseconds: 1000),
                              padding: const EdgeInsets.only(bottom: 2.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
