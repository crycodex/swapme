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
        return const CreateSwapLayout();
      },
    );
  }
}
