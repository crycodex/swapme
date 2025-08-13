import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/swap_item_model.dart';
import '../swap/swap_controller.dart';

class HomeController extends GetxController {
  // Índices: 0: home, 1: store, 2: swaps, 3: messages, 4: profile
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;
  
  // Swap controller for getting user swaps
  final SwapController _swapController = Get.put(SwapController());
  
  // User swaps stream
  Stream<List<SwapItemModel>> get userSwaps => _swapController.getUserSwaps();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
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
}
