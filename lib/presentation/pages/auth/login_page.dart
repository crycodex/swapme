import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/login_controller.dart';
import '../../widgets/organisms/login_layout.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          body: LoginLayout(
            onLoginPressed: () => controller.handleLoginPressed(context),
            onGoogleLoginPressed: () =>
                controller.handleGoogleLoginPressed(context),
            onAppleLoginPressed: () =>
                controller.handleAppleLoginPressed(context),
            onRegisterPressed: () => controller.handleRegisterPressed(context),
            isLoading: controller.isLoading.value,
          ),
        );
      },
    );
  }
}
