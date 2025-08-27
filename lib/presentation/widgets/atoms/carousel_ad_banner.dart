import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';

class CarouselAdBanner extends StatefulWidget {
  final ColorScheme colorScheme;

  const CarouselAdBanner({super.key, required this.colorScheme});

  @override
  State<CarouselAdBanner> createState() => _CarouselAdBannerState();
}

class _CarouselAdBannerState extends State<CarouselAdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailedToLoad = false;
  final AdService _adService = AdService.instance;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    try {
      // Verificar si el SDK está listo
      final bool isReady = await _adService.isSDKReady();
      if (!isReady) {
        debugPrint('[CarouselAd] SDK de AdMob no está listo');
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _isAdFailedToLoad = true;
          });
        }
        return;
      }

      _bannerAd = _adService.createBannerAd(
        adSize: AdSize.mediumRectangle, // Mejor tamaño para carousel
        onAdLoaded: () {
          debugPrint('[CarouselAd] Banner ad cargado exitosamente');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailedToLoad = false;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[CarouselAd] Error de carga de anuncio: $error');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdFailedToLoad = true;
            });
          }
        },
      );
      _bannerAd?.load();
    } catch (e) {
      debugPrint('[CarouselAd] Error al crear banner ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdFailedToLoad = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildAdContent(),
      ),
    );
  }

  Widget _buildAdContent() {
    if (_isAdLoaded && _bannerAd != null) {
      // Mostrar anuncio real de AdMob
      return Container(
        color: widget.colorScheme.surfaceContainer,
        child: Center(child: AdWidget(ad: _bannerAd!)),
      );
    }

    // Mostrar placeholder mientras carga o si falla
    return Container(
      color: widget.colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isAdFailedToLoad) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cargando anuncio...',
                style: TextStyle(
                  color: widget.colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              Icon(
                Icons.ads_click,
                size: 48,
                color: widget.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Anuncio',
                style: TextStyle(
                  color: widget.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
