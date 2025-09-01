import 'package:get/get.dart';
import '../controllers/limits/user_limits_controller.dart';
import '../services/ads_service.dart';

class LimitsBindings extends Bindings {
  @override
  void dependencies() {
    // Inicializar controlador de límites de usuario
    Get.lazyPut<UserLimitsController>(
      () => UserLimitsController(),
      fenix: true, // Mantener vivo el controlador
    );

    // Inicializar servicio de anuncios
    Get.lazyPut<AdsService>(
      () => AdsService(),
      fenix: true, // Mantener vivo el servicio
    );
  }
}
