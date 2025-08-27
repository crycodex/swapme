//get
import 'package:get/get.dart';
//models
import '../data/models/store_model.dart';
//welcome page
import '../presentation/pages/welcome/welcome_page.dart';
//login page
import '../presentation/pages/auth/login_page.dart';
//home page
import '../presentation/pages/home/home_page.dart';
//profile
import '../presentation/pages/profile/edit_profile_page.dart';
import '../presentation/pages/profile/swap_history_page.dart';
import '../presentation/pages/profile/user_ratings_page.dart';
import '../presentation/pages/profile/seller_profile_page.dart';
//swap
import '../presentation/pages/swap/create_swap_page.dart';
import '../presentation/pages/swap/swap_detail_page.dart';
// store
import '../presentation/pages/store/store_detail_page.dart';
import '../presentation/pages/store/store_item_detail_page.dart';
import '../presentation/pages/store/store_item_editor_page.dart';
import '../presentation/pages/store/create_store_item_page.dart';
import '../presentation/pages/store/store_ratings_page.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String editProfile = '/edit-profile';
  static const String swapHistory = '/swap-history';
  static const String userRatings = '/user-ratings';
  static const String sellerProfile = '/seller-profile';
  static const String createSwap = '/create-swap';
  static const String swapDetail = '/swap-detail';
  static const String storeDetail = '/store-detail';
  static const String storeItemDetail = '/store-item-detail';
  static const String storeEditor = '/store-editor';
  static const String storeItemEditor = '/store-item-editor';
  static const String createStoreItem = '/create-store-item';
  static const String storeRatings = '/store-ratings';

  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
    GetPage(
      name: Routes.swapHistory,
      page: () => const SwapHistoryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.userRatings,
      page: () {
        final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
        return UserRatingsPage(
          userId: args['userId'] as String,
          userName: args['userName'] as String,
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.sellerProfile,
      page: () => const SellerProfilePage(),
      transition: Transition.rightToLeft,
    ),
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
      name: Routes.storeItemDetail,
      page: () => const StoreItemDetailPage(),
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
    GetPage(
      name: Routes.storeRatings,
      page: () {
        final StoreModel store = Get.arguments as StoreModel;
        return StoreRatingsPage(store: store);
      },
      transition: Transition.rightToLeft,
    ),
  ];
}
