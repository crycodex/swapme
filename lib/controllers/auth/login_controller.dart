import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.home);
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
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.home);
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
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.home);
    } catch (e) {
      setErrorMessage('Error al iniciar sesión con Apple');
    } finally {
      isLoading.value = false;
    }
  }

  void handleRegisterPressed(BuildContext context) {
    Get.snackbar(
      'Registro',
      'Cuenta creada correctamente',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> handleForgotSubmit(BuildContext context) async {
    if (email.value.isEmpty) {
      setErrorMessage(
        'Por favor ingresa tu correo para recuperar la contraseña',
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Recuperación',
        'Te hemos enviado un correo para restablecer tu contraseña',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setErrorMessage('No se pudo enviar el correo. Inténtalo nuevamente');
    } finally {
      isLoading.value = false;
    }
  }
}
