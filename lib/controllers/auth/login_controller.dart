import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void setEmail(String value) {
    email.value = value;
    clearError();
  }

  void setPassword(String value) {
    password.value = value;
    clearError();
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  void clearError() {
    errorMessage.value = '';
  }

  Future<void> handleLoginPressed(BuildContext context) async {
    if (email.value.isEmpty || password.value.isEmpty) {
      setErrorMessage('Por favor completa todos los campos');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));

      // Aquí iría la lógica real de autenticación
      // Por ahora navegamos de vuelta a welcome
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      setErrorMessage('Error al iniciar sesión: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleGoogleLoginPressed(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Simular login con Google
      await Future.delayed(const Duration(seconds: 1));

      // Por ahora navegamos de vuelta a welcome
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      setErrorMessage('Error al iniciar sesión con Google');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleAppleLoginPressed(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Simular login con Apple
      await Future.delayed(const Duration(seconds: 1));

      // Por ahora navegamos de vuelta a welcome
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      setErrorMessage('Error al iniciar sesión con Apple');
    } finally {
      isLoading.value = false;
    }
  }

  void handleRegisterPressed(BuildContext context) {
    // Por ahora navegamos de vuelta a welcome
    // En el futuro aquí iría la ruta de registro
    Get.offAllNamed(Routes.welcome);
  }
}
