import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/swap/swap_history_controller.dart';
import '../../../data/models/swap_history_model.dart';

class SwapHistoryPage extends GetView<SwapHistoryController> {
  const SwapHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Ensure controller is initialized
    Get.put(SwapHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de intercambios'),
        actions: [
          IconButton(
            onPressed: () {
              controller.loadUserSwapHistory();
              controller.loadUserStats();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error cargando historial',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    controller.loadUserSwapHistory();
                    controller.loadUserStats();
                  },
                  child: const Text('Intentar de nuevo'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Estadísticas del usuario
            SliverToBoxAdapter(
              child: _buildUserStatsCard(context, theme, colorScheme),
            ),

            // Lista de intercambios
            if (controller.swapHistory.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 64, color: theme.hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes intercambios aún',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuando completes tu primer intercambio aparecerá aquí',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final SwapHistoryModel swap = controller.swapHistory[index];
                  return _buildSwapHistoryCard(
                    context,
                    swap,
                    theme,
                    colorScheme,
                  );
                }, childCount: controller.swapHistory.length),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildUserStatsCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final userStats = controller.userStats.value;

            return Column(
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
                      'Mis estadísticas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Intercambios',
                        '${userStats?.totalSwaps ?? 0}',
                        Icons.swap_horiz,
                        colorScheme.primary,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Calificación',
                        userStats?.totalRatings == 0
                            ? 'N/A'
                            : '${userStats?.averageRating.toStringAsFixed(1)} ⭐',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Valoraciones',
                        '${userStats?.totalRatings ?? 0}',
                        Icons.rate_review,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSwapHistoryCard(
    BuildContext context,
    SwapHistoryModel swap,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final String currentUserId = controller.currentUserId!;
    final bool isOwner = swap.isUserTheOwner(currentUserId);
    final String otherUserName = swap.getOtherUserName(currentUserId);
    final String otherUserPhotoUrl = swap.getOtherUserPhotoUrl(currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'swap-history-${swap.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          swap.swapItemImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            swap.swapItemName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isOwner
                                    ? Icons.arrow_forward
                                    : Icons.arrow_back,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOwner
                                        ? 'Intercambiado con '
                                        : 'Obtenido de',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  Text(
                                    otherUserName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(swap.completedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage: otherUserPhotoUrl.isNotEmpty
                              ? NetworkImage(otherUserPhotoUrl)
                              : null,
                          child: otherUserPhotoUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 16,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: swap.status == SwapHistoryStatus.completed
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            swap.status == SwapHistoryStatus.completed
                                ? 'Completado'
                                : 'Cancelado',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: swap.status == SwapHistoryStatus.completed
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (swap.notes != null && swap.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      swap.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mes atrás' : '$months meses atrás';
    } else {
      final int years = (difference.inDays / 365).floor();
      return years == 1 ? '1 año atrás' : '$years años atrás';
    }
  }
}
