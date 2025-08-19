import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/swap/swap_history_controller.dart';
import '../../../data/models/rating_model.dart';
import '../../widgets/atoms/rating_stars.dart';
import '../../widgets/molecules/rating_card.dart';

class UserRatingsPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserRatingsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserRatingsPage> createState() => _UserRatingsPageState();
}

class _UserRatingsPageState extends State<UserRatingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SwapHistoryController _controller = Get.put(SwapHistoryController());

  List<RatingModel> _userRatings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserRatings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<RatingModel> ratings = await _controller.getUserRatings(
        widget.userId,
      );
      setState(() {
        _userRatings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calificaciones'),
            Text(
              widget.userName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recibidas'),
            Tab(text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatingsTab(context, theme, colorScheme),
          _buildStatsTab(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildRatingsTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userRatings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              'Sin calificaciones aún',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las calificaciones aparecerán aquí después de completar intercambios',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserRatings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userRatings.length,
        itemBuilder: (context, index) {
          final RatingModel rating = _userRatings[index];
          return RatingCard(rating: rating);
        },
      ),
    );
  }

  Widget _buildStatsTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calcular estadísticas
    final int totalRatings = _userRatings.length;
    double averageRating = 0.0;
    Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    if (totalRatings > 0) {
      final int totalSum = _userRatings.fold(
        0,
        (sum, rating) => sum + rating.rating,
      );
      averageRating = totalSum / totalRatings;

      for (final RatingModel rating in _userRatings) {
        ratingDistribution[rating.rating] =
            (ratingDistribution[rating.rating] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resumen de calificaciones',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RatingStars(rating: averageRating, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              '$totalRatings valoraciones',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 1,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            children: [
                              for (int star = 5; star >= 1; star--)
                                _buildRatingBar(
                                  context,
                                  star,
                                  ratingDistribution[star] ?? 0,
                                  totalRatings,
                                  theme,
                                  colorScheme,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Comentarios destacados
          if (_userRatings.any(
            (rating) => rating.comment != null && rating.comment!.isNotEmpty,
          )) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: colorScheme.secondary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Comentarios destacados',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mostrar los comentarios mejor calificados
                    ..._userRatings
                        .where(
                          (rating) =>
                              rating.comment != null &&
                              rating.comment!.isNotEmpty &&
                              rating.rating >= 4,
                        )
                        .take(3)
                        .map(
                          (rating) => _buildHighlightedComment(
                            context,
                            rating,
                            theme,
                            colorScheme,
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBar(
    BuildContext context,
    int stars,
    int count,
    int total,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final double percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: theme.textTheme.bodySmall),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedComment(
    BuildContext context,
    RatingModel rating,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingStars(rating: rating.rating.toDouble(), size: 14),
              const Spacer(),
              Text(
                _formatDate(rating.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(rating.comment!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                backgroundImage: rating.raterPhotoUrl.isNotEmpty
                    ? NetworkImage(rating.raterPhotoUrl)
                    : null,
                child: rating.raterPhotoUrl.isEmpty
                    ? Icon(Icons.person, size: 12, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                rating.raterName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana atrás' : '$weeks semanas atrás';
    } else {
      final int months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mes atrás' : '$months meses atrás';
    }
  }
}
