//get
import 'package:get/get.dart';
//welcome page
import '../presentation/pages/welcome/welcome_page.dart';
//login page
import '../presentation/pages/auth/login_page.dart';
//home page
import '../presentation/pages/home/home_page.dart';
//profile
import '../presentation/pages/profile/edit_profile_page.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String editProfile = '/edit-profile';

  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
  ];
}
