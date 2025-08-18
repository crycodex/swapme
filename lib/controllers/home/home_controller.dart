import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/swap_item_model.dart';
import '../../data/models/store_model.dart';
import '../swap/swap_controller.dart';
import '../store/store_controller.dart';

class HomeController extends GetxController {
  // Índices: 0: home, 1: store, 2: swaps, 3: messages, 4: profile
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

  // Swap controller for getting user swaps
  final SwapController _swapController = Get.put(SwapController());
  // Store controller for getting stores
  final StoreController _storeController = Get.put(StoreController());

  // User swaps stream
  Stream<List<SwapItemModel>> get userSwaps => _swapController.getUserSwaps();
  // All swaps stream (catalog)
  Stream<List<SwapItemModel>> get allSwaps => _swapController.getAllSwaps();
  // Featured stores for carousel
  Stream<List<StoreModel>> get featuredStores => _storeController.getStores();

  // Search & filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Todos'.obs;
  final List<String> categories = const <String>[
    'Todos',
    'Camisetas',
    'Pantalones',
    'Chaquetas',
    'Calzado',
    'Accesorios',
    'Otros',
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
    // Ensure StoreController is available when needed
    Get.put(StoreController(), permanent: true);
    // Debounce de búsqueda para no recalcular en cada tecla
    ever<String>(searchQuery, (_) {});
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeIndex(int newIndex) {
    if (newIndex == currentIndex.value) return;
    currentIndex.value = newIndex;
    if (pageController.hasClients) {
      pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(newIndex);
        }
      });
    }
  }

  void handlePageChanged(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  // Derived filter
  List<SwapItemModel> filterSwaps(List<SwapItemModel> items) {
    final String q = searchQuery.value.trim().toLowerCase();
    final String cat = selectedCategory.value;
    final String? uid = _auth.currentUser?.uid;
    return items.where((SwapItemModel item) {
      final bool matchesQuery = q.isEmpty
          ? true
          : (item.name.toLowerCase().contains(q) ||
                item.description.toLowerCase().contains(q));
      final bool matchesCategory = cat == 'Todos' ? true : item.category == cat;
      final bool isNotMine = uid == null ? true : item.userId != uid;
      return matchesQuery && matchesCategory && isNotMine;
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
