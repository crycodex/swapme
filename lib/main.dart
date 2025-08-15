import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'config/theme/theme_data.dart';
import 'config/app_config.dart';
import './routes/routes.dart';
import 'splash_screen.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/welcome/welcome_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'controllers/auth/auth_controller.dart';
import 'services/notification_service.dart';
import 'services/cloud_messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de la aplicación
  debugPrint('Iniciando ${AppConfig.appName} v${AppConfig.appVersion}');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Google AdMob (temporalmente comentado)
  // await MobileAds.instance.initialize();

  // Configurar manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar servicios
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<NotificationService>(NotificationService(), permanent: true);
  Get.put<CloudMessagingService>(CloudMessagingService(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      getPages: Routes.routes,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          final User? user = snapshot.data;
          if (user != null) {
            if (user.emailVerified) {
              return const HomePage();
            }
            return const LoginPage();
          }
          return const WelcomePage();
        },
      ),
    );
  }
}
