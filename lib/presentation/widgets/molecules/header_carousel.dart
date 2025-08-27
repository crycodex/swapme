import 'package:flutter/material.dart';
import 'dart:async';
import '../atoms/carousel_slide.dart';
import '../atoms/carousel_ad_banner.dart';

class HeaderCarousel extends StatefulWidget {
  final ColorScheme colorScheme;

  const HeaderCarousel({super.key, required this.colorScheme});

  @override
  State<HeaderCarousel> createState() => _HeaderCarouselState();
}

class _HeaderCarouselState extends State<HeaderCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;
  Timer? _timer;
  List<CarouselSlide> _slides = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSlides();
  }

  void _initializeSlides() {
    // Crear slides estáticos: [local1, anuncio, local2, anuncio, local3, anuncio]
    _slides = [
      CarouselSlide.local(1),
      CarouselSlide.ad(),
      CarouselSlide.local(2),
      CarouselSlide.ad(),
      CarouselSlide.local(3),
      CarouselSlide.ad(),
    ];
    _isInitialized = true;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_isInitialized) return;
      if (_pageController.hasClients) {
        final int nextIndex = (_index + 1) % _slides.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
        decoration: BoxDecoration(
          color: widget.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (int index) {
            debugPrint('[Carousel] Página cambiada a: $index');
            setState(() {
              _index = index;
            });
          },
          itemBuilder: (_, int i) {
            final CarouselSlide slide = _slides[i];
            debugPrint(
              '[Carousel] Construyendo slide $i: ${slide.isAd ? "Anuncio" : "Local ${slide.localIndex}"}',
            );

            if (slide.isAd) {
              return CarouselAdBanner(colorScheme: widget.colorScheme);
            }
            final int imgIndex = slide.localIndex ?? 1;
            return LocalBannerSlide(
              bannerNumber: imgIndex,
              colorScheme: widget.colorScheme,
            );
          },
        ),
        // Indicadores de página
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (int i) {
              final bool active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: active ? 0.9 : 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
