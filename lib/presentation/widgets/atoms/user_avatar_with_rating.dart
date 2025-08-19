import 'package:flutter/material.dart';
import 'rating_stars.dart';

class UserAvatarWithRating extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double rating;
  final int totalRatings;
  final double avatarRadius;
  final bool showRatingBelow;

  const UserAvatarWithRating({
    super.key,
    this.photoUrl,
    required this.name,
    required this.rating,
    required this.totalRatings,
    this.avatarRadius = 24,
    this.showRatingBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
          backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
          child: (photoUrl == null || photoUrl!.isEmpty)
              ? Icon(
                  Icons.person,
                  size: avatarRadius * 0.8,
                  color: colorScheme.primary,
                )
              : null,
        ),
        if (showRatingBelow) ...[
          const SizedBox(height: 4),
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (totalRatings > 0)
            RatingStars(
              rating: rating,
              size: 12,
              showNumber: true,
              totalRatings: totalRatings,
            )
          else
            Text(
              'Sin calificaciones',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 10,
              ),
            ),
        ],
      ],
    );
  }
}
