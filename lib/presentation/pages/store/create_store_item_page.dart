import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/store/store_controller.dart';
import '../../widgets/organisms/store/create_store_item_layout.dart';

class CreateStoreItemPage extends GetView<StoreController> {
  const CreateStoreItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      init: StoreController(),
      builder: (StoreController controller) {
        return const CreateStoreItemLayout();
      },
    );
  }
}
