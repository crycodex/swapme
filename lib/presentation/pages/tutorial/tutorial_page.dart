import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/tutorial/tutorial_controller.dart';
import '../../widgets/organisms/tutorial_layout.dart';

class TutorialPage extends GetView<TutorialController> {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TutorialController>(
      init: TutorialController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: TutorialLayout(
            controller: controller,
            isLoading: controller.isLoading.value,
          ),
        );
      },
    );
  }
}
