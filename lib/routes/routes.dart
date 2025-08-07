//get
import 'package:get/get.dart';
//welcome page
import '../presentation/pages/welcome/welcome_page.dart';
//login page
import '../presentation/pages/auth/login_page.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String login = '/login';

  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage(name: Routes.login, page: () => const LoginPage()),
  ];
}
