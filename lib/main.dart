import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'config/theme/theme_data.dart';
import 'config/app_config.dart';
import './routes/routes.dart';
import 'splash_screen.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/welcome/welcome_page.dart';
import 'controllers/auth/auth_controller.dart';
import 'services/notification_service.dart';
import 'services/cloud_messaging_service.dart';
import 'services/ad_service.dart';
import 'services/content_moderation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de la aplicación
  debugPrint('Iniciando ${AppConfig.appName} v${AppConfig.appVersion}');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar servicios core primero
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<NotificationService>(NotificationService(), permanent: true);
  Get.put<CloudMessagingService>(CloudMessagingService(), permanent: true);
  Get.put<AdService>(AdService(), permanent: true);
  Get.put<ContentModerationService>(
    ContentModerationService(),
    permanent: true,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperar un tiempo mínimo para mostrar el splash screen
    await Future.delayed(const Duration(milliseconds: 2000));

    // Verificar la persistencia de la sesión de Firebase Auth
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint('Usuario persistente encontrado: ${currentUser.email}');
        debugPrint('Email verificado: ${currentUser.emailVerified}');
      } else {
        debugPrint('No hay usuario persistente');
      }
    } catch (e) {
      debugPrint('Error verificando persistencia de sesión: $e');
    }

    // Inicializar Cloud Messaging Service después de que la app esté lista
    try {
      Get.put<CloudMessagingService>(CloudMessagingService());
      final CloudMessagingService cloudMessagingService =
          Get.put<CloudMessagingService>(CloudMessagingService());
      await cloudMessagingService.initializeWhenReady();
      debugPrint('Cloud Messaging Service inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando Cloud Messaging Service: $e');
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      getPages: Routes.routes,
      home: _isInitialized
          ? StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                final User? user = snapshot.data;
                if (user != null) {
                  // Usuario autenticado - verificar estado de email
                  if (user.emailVerified) {
                    return const HomePage();
                  } else {
                    // Usuario autenticado pero email no verificado - mantener en WelcomePage
                    // pero mostrar opciones de login para reenviar verificación
                    return const WelcomePage();
                  }
                }
                // Usuario no autenticado - ir a WelcomePage
                return const WelcomePage();
              },
            )
          : const SplashScreen(),
    );
  }
}
