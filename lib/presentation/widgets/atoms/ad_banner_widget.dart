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

// Control global para limitar ads simultáneos
class _BottomAdGlobalController {
  static final _BottomAdGlobalController _instance =
      _BottomAdGlobalController._internal();
  factory _BottomAdGlobalController() => _instance;
  _BottomAdGlobalController._internal();

  int _activeAds = 0;
  static const int _maxActiveAds = 1; // Solo 1 ad activo a la vez

  bool canCreateAd() => _activeAds < _maxActiveAds;

  void registerAd() {
    _activeAds++;
    debugPrint('[BottomAdGlobal] Ads activos: $_activeAds');
  }

  void unregisterAd() {
    if (_activeAds > 0) {
      _activeAds--;
      debugPrint('[BottomAdGlobal] Ads activos: $_activeAds');
    }
  }
}

// Manager para ads en bottom navigation - singleton para evitar duplicados
class BottomAdManager {
  static BottomAdManager? _instance;
  static BottomAdManager get instance {
    _instance ??= BottomAdManager._internal();
    return _instance!;
  }

  BottomAdManager._internal();

  final AdService adService = AdService.instance;
  final _BottomAdGlobalController _globalController =
      _BottomAdGlobalController();

  // Crear una nueva instancia de BannerAd para cada widget
  BannerAd? createBottomAd({
    required VoidCallback onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    // Verificar si podemos crear un nuevo ad
    if (!_globalController.canCreateAd()) {
      debugPrint(
        '[BottomAdManager] No se puede crear más ads (límite alcanzado)',
      );
      onAdFailedToLoad(LoadAdError(0, 'Límite de ads alcanzado', '', null));
      return null;
    }

    try {
      final bannerAd = adService.createBannerAd(
        adSize: AdSize.banner,
        onAdLoaded: () {
          debugPrint('[BottomAdManager] Bottom ad cargado exitosamente');
          _globalController.registerAd();
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[BottomAdManager] Error cargando bottom ad: $error');
          onAdFailedToLoad(error);
        },
      );

      return bannerAd;
    } catch (e) {
      debugPrint('[BottomAdManager] Error al crear bottom ad: $e');
      onAdFailedToLoad(LoadAdError(0, e.toString(), '', null));
      return null;
    }
  }

  void unregisterAd() {
    _globalController.unregisterAd();
  }
}

// Widget especializado para banner en bottom navigation con cache
class BottomAdBannerWidget extends StatefulWidget {
  const BottomAdBannerWidget({super.key});

  @override
  State<BottomAdBannerWidget> createState() => _BottomAdBannerWidgetState();
}

class _BottomAdBannerWidgetState extends State<BottomAdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdFailedToLoad = false;
  late BottomAdManager _adManager;

  @override
  void initState() {
    super.initState();
    _adManager = BottomAdManager.instance;

    // Cargar ad con delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadBottomAd();
      }
    });

    // Verificar periódicamente si el ad sigue siendo válido
    Future.delayed(const Duration(minutes: 5), _checkAdValidity);
  }

  Future<void> _loadBottomAd() async {
    if (_isAdLoaded || _isAdLoading) return;

    _isAdLoading = true;
    _isAdFailedToLoad = false;

    try {
      final bool isReady = await _adManager.adService.isSDKReady();
      if (!isReady) {
        debugPrint('[BottomAdBannerWidget] SDK de AdMob no está listo');
        if (mounted) {
          setState(() {
            _isAdLoading = false;
            _isAdFailedToLoad = true;
          });
        }
        return;
      }

      _bannerAd = _adManager.createBottomAd(
        onAdLoaded: () {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
              _isAdFailedToLoad = false;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[BottomAdBannerWidget] Error cargando ad: $error');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdLoading = false;
              _isAdFailedToLoad = true;
            });
          }
        },
      );

      if (_bannerAd != null) {
        await _bannerAd!.load();
      }
    } catch (e) {
      debugPrint('[BottomAdBannerWidget] Error al crear ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdLoading = false;
          _isAdFailedToLoad = true;
        });
      }
    }
  }

  void _checkAdValidity() {
    if (!mounted) return;

    if (!_isAdLoaded && !_isAdLoading) {
      debugPrint('[BottomAdBannerWidget] Ad no válido, recargando...');
      _loadBottomAd();
    }

    // Programar siguiente verificación
    Future.delayed(const Duration(minutes: 5), _checkAdValidity);
  }

  @override
  void dispose() {
    if (_isAdLoaded) {
      _adManager.unregisterAd();
    }
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Si el ad falló al cargar, no mostrar nada
    if (_isAdFailedToLoad) {
      return const SizedBox.shrink();
    }

    // Si el ad no está cargado, mostrar placeholder
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
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

    // Mostrar el ad
    return Container(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _bannerAd!),
      ),
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
