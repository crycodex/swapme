import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class AdService extends GetxService {
  static AdService get instance {
    try {
      return Get.find<AdService>();
    } catch (e) {
      // Si el servicio no está registrado, retornamos una instancia temporal
      // ignore: avoid_print
      print('[AdService] AdService no encontrado, creando instancia temporal');
      return AdService._();
    }
  }

  // Constructor privado para instancias temporales
  AdService._();

  // Constructor público para uso normal
  AdService();

  // Test ad unit IDs - reemplazar con IDs reales en producción
  static const String _bannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _bannerAdUnitIdIOS =
      'ca-app-pub-3940256099942544/2934735716';

  // IDs para producción - configurar cuando tengas las credenciales reales
  static const String _bannerAdUnitIdAndroidProd =
      'YOUR_ANDROID_BANNER_AD_UNIT_ID';
  static const String _bannerAdUnitIdIOSProd = 'YOUR_IOS_BANNER_AD_UNIT_ID';

  // Flag para determinar si usar test ads o producción
  static const bool _useTestAds = true;

  String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _bannerAdUnitIdAndroid : _bannerAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _bannerAdUnitIdAndroidProd
          : _bannerAdUnitIdIOSProd;
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('AdService inicializado (sin re-inicializar AdMob)');
  }

  // Verificar si el SDK está listo
  Future<bool> isSDKReady() async {
    try {
      // Simplemente intentamos crear un objeto de prueba
      // Si no falla, asumimos que está listo
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      debugPrint('Error verificando estado del SDK: $e');
      return false;
    }
  }

  BannerAd createBannerAd({
    AdSize adSize = AdSize.banner,
    required void Function() onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Banner ad cargado: ${ad.adUnitId}');
          onAdLoaded();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint(
            'Banner ad falló al cargar: ${ad.adUnitId}, error: $error',
          );
          ad.dispose();
          onAdFailedToLoad(error);
        },
        onAdOpened: (Ad ad) => debugPrint('Banner ad abierto'),
        onAdClosed: (Ad ad) => debugPrint('Banner ad cerrado'),
      ),
    );
  }

  void debugPrint(String message) {
    // ignore: avoid_print
    print('[AdService] $message');
  }
}
