import 'package:flutter/foundation.dart';

/// Configuración de la aplicación
class AppConfig {
  static const String appName = 'SwapMe';
  static const String appVersion = '1.0.0';
  
  // Configuraciones de Firebase (ya manejadas en firebase_options.dart)
  static const bool enableFirebase = true;
  
  // Configuraciones de la app
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedLanguages = ['es', 'en'];
  
  // Configuraciones de debug
  static bool get isDebugMode => kDebugMode;
  
  // Configuraciones de API (si las necesitas en el futuro)
  static const String defaultApiBaseUrl = 'https://api.example.com';
  static const int defaultApiTimeout = 30000; // 30 segundos
  
  // Configuraciones de UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// Obtener configuración específica de la plataforma
  static T getPlatformConfig<T>({
    required T android,
    required T ios,
    required T web,
    T? defaultValue,
  }) {
    if (defaultValue != null) return defaultValue;
    
    if (kIsWeb) return web;
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }
}
