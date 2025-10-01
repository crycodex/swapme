import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/limits/user_limits_controller.dart';

class AdsService extends GetxService {
  final UserLimitsController _userLimitsController = Get.put(
    UserLimitsController(),
  );

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  final RxBool isBannerAdLoaded = false.obs;
  final RxBool isInterstitialAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAds();
  }

  void _initializeAds() {
    // Inicializar Google Mobile Ads
    MobileAds.instance.initialize();
  }

  // Cargar anuncio banner
  void loadBannerAd() {
    if (!_userLimitsController.userHasAds()) return;

    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdLoaded.value = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  // Cargar anuncio intersticial
  void loadInterstitialAd() {
    if (!_userLimitsController.userHasAds()) return;

    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;
        },
      ),
    );
  }

  // Mostrar anuncio intersticial
  Future<void> showInterstitialAd() async {
    if (!_userLimitsController.userHasAds()) return;
    if (_interstitialAd == null) return;

    await _interstitialAd!.show();
    _interstitialAd = null;
    isInterstitialAdLoaded.value = false;

    // Recargar el anuncio
    loadInterstitialAd();
  }

  // Mostrar anuncio después de un swap
  Future<void> showAdAfterSwap() async {
    if (!_userLimitsController.userHasAds()) return;

    // Mostrar anuncio intersticial con 50% de probabilidad
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      await showInterstitialAd();
    }
  }

  // Obtener ID del anuncio banner según la plataforma
  String _getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-6468767225905546/5963869932';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-6468767225905546/1592577751';
    }
    // Fallback para otras plataformas (usar ID de prueba)
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  // Obtener ID del anuncio intersticial según la plataforma
  String _getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-6468767225905546/2480855614';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-6468767225905546/5542773857';
    }
    // Fallback para otras plataformas (usar ID de prueba)
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  // Limpiar recursos
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }

  @override
  void onClose() {
    dispose();
    super.onClose();
  }
}
