import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/welcome/welcome_controller.dart';
import '../../widgets/organisms/welcome_layout.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomeController>(
      init: WelcomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: WelcomeLayout(
            onStartPressed: () => controller.handleStartPressed(context),
            isLoading: controller.isLoading.value,
          ),
        );
      },
    );
  }
}
