import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/rating_model.dart';
import '../../../controllers/store/store_controller.dart';
import '../../widgets/molecules/store_rating_card.dart';

class StoreRatingsPage extends StatelessWidget {
  final StoreModel store;

  const StoreRatingsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    final StoreController controller = Get.put(StoreController());

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text('Calificaciones de ${store.name}'),
        backgroundColor: color.surface,
      ),
      body: StreamBuilder<List<RatingModel>>(
        stream: controller.getStoreRatings(store.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<RatingModel> ratings = snapshot.data ?? [];

          if (ratings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    'Sin calificaciones',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta tienda aún no tiene calificaciones',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header con resumen de calificaciones
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StoreRatingCard(store: store, ratings: ratings),
                ),
              ),
              // Lista de todas las calificaciones
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final rating = ratings[index];
                  return _RatingListItem(rating: rating);
                }, childCount: ratings.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _RatingListItem extends StatelessWidget {
  final RatingModel rating;

  const _RatingListItem({required this.rating});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: rating.raterPhotoUrl.isNotEmpty
                    ? NetworkImage(rating.raterPhotoUrl)
                    : null,
                child: rating.raterPhotoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: color.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.raterName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(rating.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rating.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minutos';
    } else {
      return 'hace un momento';
    }
  }
}
