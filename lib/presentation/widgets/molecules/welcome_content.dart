import 'package:flutter/material.dart';
import '../atoms/animated_text.dart';
import '../atoms/animated_icon.dart' as custom;
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

    final slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
                const SizedBox(height: 20),

                // Sol rotatorio personalizado en el lado derecho
                Align(
                  alignment: Alignment.topRight,
                  child: RotatingSun(
                    size: 100,
                    animation: bounceAnimation,
                    scaleAnimation: scaleAnimation,
                  ),
                ),

                const SizedBox(height: 30),

                // Textos principales con animación escalonada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Intercambia"
                      AnimatedText(
                        text: 'Intercambia,',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                        animation: slideAnimation,
                        padding: const EdgeInsets.only(bottom: 4.0),
                      ),

                      // "Descubre"
                      AnimatedText(
                        text: 'Descubre,',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                        animation: slideAnimation,
                        padding: const EdgeInsets.only(bottom: 4.0),
                      ),

                      // "Estrena" con fondo especial
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedText(
                          text: 'Estrena',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                          animation: scaleAnimation,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contenedor con camiseta y texto
                      Row(
                        children: [
                          // Camiseta con animación de respiración
                          BreathingCloth(
                            size: 150,
                            animation: bounceAnimation,
                            scaleAnimation: scaleAnimation,
                          ),

                          const SizedBox(width: 12),

                          // Textos "Dale una nueva vida a tu clóset"
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedText(
                                  text: 'Dale',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                      ),
                                  animation: slideAnimation,
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                ),
                                AnimatedText(
                                  text: 'una nueva',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                      ),
                                  animation: slideAnimation,
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                ),
                                AnimatedText(
                                  text: 'vida a tu',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                      ),
                                  animation: slideAnimation,
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                ),
                                AnimatedText(
                                  text: 'clóset',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.pink[200],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                      ),
                                  animation: slideAnimation,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Flecha animada apuntando al botón
                      Align(
                        alignment: Alignment.bottomRight,
                        child: custom.AnimatedIcon(
                          icon: Icons.keyboard_arrow_down,
                          size: 30,
                          color: Colors.white,
                          animation: bounceAnimation,
                          scaleAnimation: scaleAnimation,
                        ),
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
