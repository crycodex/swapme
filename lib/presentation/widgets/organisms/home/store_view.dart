import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/store/store_controller.dart';
import '../../../../data/models/store_model.dart';
import '../../../../routes/routes.dart';

class StoreView extends GetView<StoreController> {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: CustomScrollView(
        slivers: [
          // Header mejorado
          SliverAppBar(
            pinned: true,
            backgroundColor: color.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiendas',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color.onSurface,
                  ),
                ),
                Text(
                  'Descubre y conecta con vendedores',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            expandedHeight: 0,
            floating: false,
          ),

          // Barra de búsqueda y botón de mi tienda
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Buscar tiendas...',
                        hintStyle: TextStyle(color: color.onSurfaceVariant),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: color.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: color.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Obx(() {
                          return controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.updateSearchQuery('');
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: color.onSurfaceVariant,
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StreamBuilder<StoreModel?>(
                    stream: controller.getMyStore(),
                    builder: (context, snapshot) {
                      final bool hasStore = snapshot.data != null;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: hasStore
                              ? () => Get.toNamed(
                                  Routes.storeDetail,
                                  arguments: snapshot.data,
                                )
                              : () => Get.toNamed(Routes.storeEditor),
                          style: IconButton.styleFrom(
                            backgroundColor: color.primary,
                            foregroundColor: color.onPrimary,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: Icon(
                            hasStore
                                ? Icons.storefront_rounded
                                : Icons.add_business_rounded,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Lista de tiendas
          SliverToBoxAdapter(
            child: Obx(() {
              // Trigger rebuild when search query changes
              controller.searchQuery.value;

              return StreamBuilder<List<StoreModel>>(
                stream: controller.getStores(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      margin: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: color.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando tiendas...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final List<StoreModel> allStores =
                      snapshot.data ?? <StoreModel>[];
                  final List<StoreModel> filteredStores = controller
                      .filterStores(allStores);

                  if (allStores.isEmpty) {
                    return Container(
                      height: 300,
                      margin: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: color.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                size: 48,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aún no hay tiendas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: color.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sé el primero en crear una tienda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredStores.isEmpty &&
                      controller.searchQuery.value.isNotEmpty) {
                    return Container(
                      height: 200,
                      margin: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: color.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron tiendas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: color.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otro término de búsqueda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.searchQuery.value.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '${filteredStores.length} resultado${filteredStores.length != 1 ? 's' : ''} encontrado${filteredStores.length != 1 ? 's' : ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        ...filteredStores.map(
                          (store) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _StoreCard(
                              store: store,
                              theme: theme,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;
  final ThemeData theme;
  final ColorScheme color;

  const _StoreCard({
    required this.store,
    required this.theme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Get.toNamed(Routes.storeDetail, arguments: store),
      child: Container(
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de la tienda
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: store.bannerUrl.isEmpty
                    ? Container(
                        color: color.surfaceContainerHighest,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 48,
                          color: color.onSurfaceVariant,
                        ),
                      )
                    : Image.network(
                        store.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: color.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ),

            // Información de la tienda
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Logo de la tienda
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.outline.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: store.logoUrl.isEmpty
                              ? Container(
                                  width: 56,
                                  height: 56,
                                  color: color.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    size: 28,
                                    color: color.onSurfaceVariant,
                                  ),
                                )
                              : Image.network(
                                  store.logoUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: color.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 28,
                                      color: color.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Información principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estadísticas de la tienda
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Cantidad de items
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              size: 16,
                              color: color.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${store.itemsCount} items',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Indicador de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: store.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : color.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              store.isActive
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 8,
                              color: store.isActive
                                  ? Colors.green
                                  : color.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.isActive ? 'Activa' : 'Inactiva',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: store.isActive
                                    ? Colors.green.shade700
                                    : color.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
