import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../../widgets/organisms/swap/create_swap_layout.dart';

class CreateSwapPage extends GetView<SwapController> {
  const CreateSwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwapController>(
      init: SwapController(),
      builder: (SwapController controller) {
        return PopScope(
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) {
              // Liberar la cámara cuando se salga de la página
              await controller.disposeCamera();
            }
          },
          child: const CreateSwapLayout(),
        );
      },
    );
  }
}
