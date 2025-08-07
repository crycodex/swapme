import 'package:flutter/material.dart';
import 'package:get/get.dart';
//theme personalizado
import 'config/theme/theme_data.dart';
//splash screen
import 'splash_screen.dart';
//routes
import './routes/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwapMe',
      // Usar el tema claro personalizado
      theme: AppTheme.light,
      // Usar el tema oscuro personalizado
      darkTheme: AppTheme.dark,
      // Usar tema oscuro o claro basado en la configuración del sistema
      themeMode: ThemeMode.system,
      // Configurar las rutas
      getPages: Routes.routes,
      // Página inicial - splash screen
      home: const SplashScreen(),
    );
  }
}
