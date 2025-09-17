import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
  });

  bool _shouldShowGoogleButton() {
    if (kIsWeb) return false; // Web: no mostrar Google
    if (Platform.isAndroid) return true; // Android: mostrar Google
    if (Platform.isIOS) return true; // iOS: mostrar Google
    return false;
  }

  bool _shouldShowAppleButton() {
    if (kIsWeb) return false; // Web: no mostrar Apple
    if (Platform.isAndroid) return false; // Android: no mostrar Apple
    if (Platform.isIOS) return true; // iOS: mostrar Apple
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldShowGoogle = _shouldShowGoogleButton();
    final shouldShowApple = _shouldShowAppleButton();

    // Si no hay botones para mostrar, retornar un widget vacío
    if (!shouldShowGoogle && !shouldShowApple) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Botón de Google (solo si debe mostrarse)
        if (shouldShowGoogle) ...[
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onGooglePressed,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de Google
                      Image.asset(
                        'assets/app/login/google.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Google',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // Espaciado entre botones (solo si ambos botones están presentes)
        if (shouldShowGoogle && shouldShowApple) const SizedBox(height: 10),

        // Botón de Apple (solo si debe mostrarse)
        if (shouldShowApple)
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onApplePressed,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de Apple
                      Image.asset(
                        'assets/app/login/apple.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Apple',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
