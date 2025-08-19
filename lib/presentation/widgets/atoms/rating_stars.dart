import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final bool showNumber;
  final int? totalRatings;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color = Colors.amber,
    this.showNumber = false,
    this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final double starValue = index + 1;

          Widget star;
          if (rating >= starValue) {
            // Estrella completa
            star = Icon(Icons.star, size: size, color: color);
          } else if (rating >= starValue - 0.5) {
            // Media estrella
            star = Icon(Icons.star_half, size: size, color: color);
          } else {
            // Estrella vacía
            star = Icon(
              Icons.star_border,
              size: size,
              color: color.withValues(alpha: 0.3),
            );
          }

          return star;
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            totalRatings != null
                ? '${rating.toStringAsFixed(1)} ($totalRatings)'
                : rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }
}
