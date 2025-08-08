import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Índices: 0: home, 1: store, 2: swaps, 3: messages, 4: profile
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

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
    pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void handlePageChanged(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}
