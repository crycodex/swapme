import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'config/theme/theme_data.dart';
import './routes/routes.dart';
import 'splash_screen.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/welcome/welcome_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'controllers/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put<AuthController>(AuthController(), permanent: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwapMe',
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
