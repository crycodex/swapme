import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString registerName = ''.obs;
  final RxString registerEmail = ''.obs;
  final RxString registerPassword = ''.obs;
  final RxString registerPasswordConfirm = ''.obs;
  final RxBool registrationCompleted = false.obs;

  void setEmail(String value) {
    email.value = value;
    clearError();
  }

  void setPassword(String value) {
    password.value = value;
    clearError();
  }

  void setRegisterName(String value) {
    registerName.value = value;
  }

  void setRegisterEmail(String value) {
    registerEmail.value = value;
  }

  void setRegisterPassword(String value) {
    registerPassword.value = value;
  }

  void setRegisterPasswordConfirm(String value) {
    registerPasswordConfirm.value = value;
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  void clearError() {
    errorMessage.value = '';
  }

  AuthController _getAuth() {
    return Get.isRegistered<AuthController>()
        ? Get.put(AuthController())
        : Get.put(AuthController());
  }

  Future<void> handleLoginPressed(BuildContext context) async {
    if (email.value.isEmpty || password.value.isEmpty) {
      setErrorMessage('Por favor completa todos los campos');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final AuthController auth = _getAuth();
      await auth.login(
        email: email.value,
        password: password.value,
        onSuccess: () => Get.offAllNamed(Routes.home),
        onError: (String msg) => setErrorMessage(msg),
      );
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
      final AuthController auth = _getAuth();
      await auth.loginWithGoogle();
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
      final AuthController auth = _getAuth();
      await auth.loginWithApple();
    } catch (e) {
      setErrorMessage('Error al iniciar sesión con Apple');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleRegisterPressed(BuildContext context) async {
    if (registerName.value.isEmpty ||
        registerEmail.value.isEmpty ||
        registerPassword.value.isEmpty ||
        registerPasswordConfirm.value.isEmpty) {
      setErrorMessage('Por favor completa todos los campos');
      return;
    }
    if (registerPassword.value != registerPasswordConfirm.value) {
      setErrorMessage('Las contraseñas no coinciden');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final AuthController auth = _getAuth();
      await auth.register(
        email: registerEmail.value,
        password: registerPassword.value,
        name: registerName.value,
        onSuccess: () {
          registrationCompleted.value = true;
          Get.snackbar(
            'Registro exitoso',
            'Te enviamos un correo para verificar tu cuenta. Revisa tu bandeja.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          Get.offAllNamed(Routes.login);
        },
        onError: (String msg) => setErrorMessage(msg),
      );
    } catch (e) {
      setErrorMessage('No se pudo registrar: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
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
      final AuthController auth = _getAuth();
      await auth.recoverPassword(
        email: email.value,
        onSuccess: () => Get.snackbar(
          'Recuperación',
          'Te hemos enviado un correo para restablecer tu contraseña',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        ),
        onError: (String msg) => setErrorMessage(msg),
      );
    } catch (e) {
      setErrorMessage('No se pudo enviar el correo. Inténtalo nuevamente');
    } finally {
      isLoading.value = false;
    }
  }
}
