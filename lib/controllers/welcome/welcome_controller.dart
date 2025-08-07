import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/pages/auth/login_page.dart';

class WelcomeController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  Future<void> handleStartPressed(BuildContext context) async {
    isLoading.value = true;

    try {
      // Simular una carga
      await Future.delayed(const Duration(milliseconds: 1500));

      // Navegar a la página de login
      Get.off(() => const LoginPage());
    } catch (error) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void resetError() {
    hasError.value = false;
    errorMessage.value = '';
  }
}
