import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? elevation;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailedToLoad = false;
  final AdService _adService = AdService.instance;

  @override
  void initState() {
    super.initState();
    // Retraso mayor para asegurar que AdMob esté inicializado
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  void _loadBannerAd() async {
    try {
      // Verificar si el SDK está listo
      final bool isReady = await _adService.isSDKReady();
      if (!isReady) {
        debugPrint('SDK de AdMob no está listo, ocultando anuncio');
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _isAdFailedToLoad = true;
          });
        }
        return;
      }

      _bannerAd = _adService.createBannerAd(
        adSize: widget.adSize,
        onAdLoaded: () {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailedToLoad = false;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Error de carga de anuncio: $error');
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
      debugPrint('Error al crear banner ad: $e');
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (_isAdFailedToLoad) {
      // Retornar un widget vacío si el anuncio falló al cargar
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || _bannerAd == null) {
      // Mostrar placeholder mientras carga
      return Container(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    Widget adWidget = Container(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: widget.borderRadius,
        boxShadow: widget.elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: widget.elevation!,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: AdWidget(ad: _bannerAd!),
      ),
    );

    return adWidget;
  }
}

// Widget especializado para banner en bottom navigation
class BottomAdBannerWidget extends StatelessWidget {
  const BottomAdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AdBannerWidget(
      adSize: AdSize.banner,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      elevation: 4,
    );
  }
}

// Widget especializado para banner en profile
class ProfileAdBannerWidget extends StatelessWidget {
  const ProfileAdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AdBannerWidget(
      adSize: AdSize.mediumRectangle,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: colorScheme.surfaceContainerHighest,
      elevation: 2,
    );
  }
}

// Widget especializado para banner en slider/carousel
class SliderAdBannerWidget extends StatelessWidget {
  const SliderAdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AdBannerWidget(
      adSize: AdSize.largeBanner,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: colorScheme.surfaceContainer,
      elevation: 6,
    );
  }
}
