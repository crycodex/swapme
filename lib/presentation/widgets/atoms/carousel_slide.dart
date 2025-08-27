import 'package:flutter/material.dart';

class CarouselSlide {
  final int? localIndex;
  final bool isAd;
  const CarouselSlide._({this.localIndex, required this.isAd});

  factory CarouselSlide.local(int index) =>
      CarouselSlide._(localIndex: index, isAd: false);
  factory CarouselSlide.ad() => const CarouselSlide._(isAd: true);
}

class LocalBannerSlide extends StatelessWidget {
  final int bannerNumber;
  final ColorScheme colorScheme;

  const LocalBannerSlide({
    super.key,
    required this.bannerNumber,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/app/banner/$bannerNumber.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AdPlaceholderSlide extends StatelessWidget {
  final ColorScheme colorScheme;

  const AdPlaceholderSlide({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: colorScheme.primary.withValues(alpha: 0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ads_click, size: 48, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  'Anuncio',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
