import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class TutorialController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;
  final isLoading = false.obs;

  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: 'Moda Rápida',
      description:
          'Descubre las últimas tendencias y encuentra tu estilo perfecto en segundos',
      icon: Icons.flash_on,
      color: Colors.orange,
    ),
    TutorialStep(
      title: 'Toma una Foto',
      description:
          'Captura tu outfit o artículo favorito para compartir con la comunidad',
      icon: Icons.camera_alt,
      color: Colors.blue,
    ),
    TutorialStep(
      title: 'Intercambia',
      description:
          'Conecta con otros usuarios y realiza intercambios seguros y divertidos',
      icon: Icons.swap_horiz,
      color: Colors.green,
    ),
    TutorialStep(
      title: 'Contribuye al Planeta',
      description:
          'Reduce el desperdicio textil y dale una segunda vida a tus prendas',
      icon: Icons.eco,
      color: Colors.teal,
    ),
    TutorialStep(
      title: 'Genera Ingresos',
      description:
          'Monetiza tu guardarropa vendiendo o intercambiando tus prendas',
      icon: Icons.attach_money,
      color: Colors.purple,
    ),
  ];

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < tutorialSteps.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipTutorial() {
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    isLoading.value = true;

    try {
      // Simular una pequeña carga
      await Future.delayed(const Duration(milliseconds: 500));

      // Navegar a la página de login
      Get.offAllNamed(Routes.login);
    } catch (error) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'No se pudo cargar la aplicación',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
