import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home/home_controller.dart';
import '../../../data/models/swap_item_model.dart';
import '../atoms/section_title.dart';
import 'swap_item_card.dart';

class SwapsSection extends StatelessWidget {
  final HomeController controller;
  final Stream<List<SwapItemModel>>? streamOverride;
  final void Function(SwapItemModel)? onItemTap;

  const SwapsSection({
    super.key,
    required this.controller,
    this.streamOverride,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: streamOverride == null ? 'Mis Swaps' : 'Explorar',
            subtitle: streamOverride == null
                ? 'Artículos que has subido'
                : 'Descubre prendas para intercambiar',
            onSeeAll: () {
              // Navigate to full swaps list
            },
          ),
        ),
        const SizedBox(height: 2),

        Obx(() {
          // Dependencias reactivas explícitas para que el catálogo se
          // reconstruya al cambiar búsqueda o categoría
          final String _ = controller.searchQuery.value;
          controller.selectedCategory.value;
          return StreamBuilder<List<SwapItemModel>>(
            stream: streamOverride ?? controller.userSwaps,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(context);
              }

              final List<SwapItemModel> all = snapshot.data ?? [];
              final List<SwapItemModel> swaps = streamOverride == null
                  ? all
                  : controller.filterSwaps(all);

              if (swaps.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildSwapsList(context, swaps);
            },
          );
        }),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  // Error state removido del flujo principal para evitar romper la UX.

  Widget _buildEmptyState(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isCatalog = streamOverride != null;

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCatalog ? Icons.search_rounded : Icons.sync_alt_rounded,
                color: colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCatalog ? 'No hay prendas disponibles' : 'No tienes swaps aún',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCatalog
                  ? 'Vuelve más tarde o ajusta los filtros'
                  : 'Toca el botón + para crear tu primer swap',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapsList(BuildContext context, List<SwapItemModel> swaps) {
    final bool isHorizontal = streamOverride == null;
    if (isHorizontal) {
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final SwapItemModel swap = swaps[index];
            return SwapItemCard(
              swapItem: swap,
              onTap: () => onItemTap?.call(swap),
            );
          },
        ),
      );
    }
    // Grid para explorar
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.76,
        ),
        itemCount: swaps.length,
        itemBuilder: (BuildContext context, int index) {
          final SwapItemModel swap = swaps[index];
          return SwapItemCard(
            swapItem: swap,
            onTap: () => onItemTap?.call(swap),
          );
        },
      ),
    );
  }
}
