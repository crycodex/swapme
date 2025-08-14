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
//swap
import '../presentation/pages/swap/create_swap_page.dart';
import '../presentation/pages/swap/swap_detail_page.dart';
// store
import '../presentation/pages/store/store_detail_page.dart';
import '../presentation/pages/store/store_item_editor_page.dart';
import '../presentation/pages/store/create_store_item_page.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String editProfile = '/edit-profile';
  static const String createSwap = '/create-swap';
  static const String swapDetail = '/swap-detail';
  static const String storeDetail = '/store-detail';
  static const String storeEditor = '/store-editor';
  static const String storeItemEditor = '/store-item-editor';
  static const String createStoreItem = '/create-store-item';

  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
    GetPage(
      name: Routes.createSwap,
      page: () => const CreateSwapPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: Routes.swapDetail,
      page: () => const SwapDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.storeDetail,
      page: () => const StoreDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.storeEditor,
      page: () => const StoreEditorPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.storeItemEditor,
      page: () => const StoreItemEditorPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createStoreItem,
      page: () => const CreateStoreItemPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 800),
    ),
  ];
}
