import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/store/store_controller.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_item_model.dart';
import '../../../data/models/rating_model.dart';
import '../../../routes/routes.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../../../data/models/swap_item_model.dart';
import '../../widgets/molecules/store_rating_card.dart';
import 'store_ratings_page.dart';

class StoreDetailPage extends GetView<StoreController> {
  const StoreDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    final StoreModel store = Get.arguments as StoreModel;
    final bool mine = controller.isOwner(store);

    return Scaffold(
      backgroundColor: color.surface,
      body: CustomScrollView(
        slivers: [
          // AppBar personalizado
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: color.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white, size: 24),
            title: Text(
              store.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              if (mine)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (String v) async {
                    if (v == 'edit') {
                      Get.to(() => const StoreEditorPage(), arguments: store);
                    } else if (v == 'delete') {
                      await controller.deleteStore(store.id);
                      Get.back();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner de la tienda
                  Hero(
                    tag: 'store-banner-${store.id}',
                    child: store.bannerUrl.isEmpty
                        ? Container(
                            color: color.surfaceContainerHighest,
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 64,
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
                                size: 64,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                  // Gradiente para legibilidad del texto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Información de la tienda
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con logo y nombre
                  Row(
                    children: [
                      // Logo de la tienda
                      Hero(
                        tag: 'store-logo-${store.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.outline.withValues(alpha: 0.2),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: store.logoUrl.isEmpty
                                ? Container(
                                    width: 80,
                                    height: 80,
                                    color: color.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 40,
                                      color: color.onSurfaceVariant,
                                    ),
                                  )
                                : Image.network(
                                    store.logoUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: color.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 40,
                                        color: color.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Información de la tienda
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              store.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: color.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Estadísticas rápidas
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
                                      color: Colors.amber.withValues(
                                        alpha: 0.3,
                                      ),
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
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
                                      color: color.primary.withValues(
                                        alpha: 0.3,
                                      ),
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: color.primary,
                                              fontWeight: FontWeight.w700,
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
                ],
              ),
            ),
          ),

          // Sección de calificaciones
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<RatingModel>>(
                stream: controller.getStoreRatings(store.id),
                builder: (context, snapshot) {
                  final List<RatingModel> ratings = snapshot.data ?? [];

                  return StoreRatingCard(
                    store: store,
                    ratings: ratings,
                    onViewAllRatings: () => Get.to(
                      () => StoreRatingsPage(store: store),
                      transition: Transition.cupertino,
                    ),
                  );
                },
              ),
            ),
          ),

          // Sección de items
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        color: color.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Productos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (mine)
                        OutlinedButton.icon(
                          onPressed: () => Get.toNamed(
                            Routes.createStoreItem,
                            arguments: <String, dynamic>{'store': store},
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Grid de items
          SliverToBoxAdapter(
            child: StreamBuilder<List<StoreItemModel>>(
              stream: controller.getItemsByStore(store.id),
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
                            'Cargando productos...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final List<StoreItemModel> items =
                    snapshot.data ?? <StoreItemModel>[];

                if (items.isEmpty) {
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
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: color.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esta tienda aún no tiene productos disponibles',
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final StoreItemModel item = items[index];
                      return _StoreItemCard(
                        item: item,
                        store: store,
                        isOwner: mine,
                        theme: theme,
                        color: color,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItemModel item;
  final StoreModel store;
  final bool isOwner;
  final ThemeData theme;
  final ColorScheme color;

  const _StoreItemCard({
    required this.item,
    required this.store,
    required this.isOwner,
    required this.theme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.storeItemDetail, arguments: item),
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
            // Imagen del producto
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        item.imageUrl,
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

                    // Botón de editar/eliminar para el dueño
                    if (isOwner)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color.surface.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: color.onSurface,
                            ),
                          ),
                          onSelected: (String v) async {
                            if (v == 'edit') {
                              Get.put(StoreController()).startEditingStoreItem(
                                item,
                              );
                              Get.toNamed(
                                Routes.createStoreItem,
                                arguments: <String, dynamic>{
                                  'store': store,
                                  'item': item,
                                },
                              );
                            } else if (v == 'delete') {
                              await Get.put(StoreController()).deleteStoreItem(
                                store.id,
                                item,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              const <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Información del producto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Chips de condición y categoría
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.condition,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.tertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Precio
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: color.primary, size: 20),
                      Text(
                        item.price.toStringAsFixed(0),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: color.primary,
                          fontWeight: FontWeight.w800,
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

class StoreEditorPage extends GetView<StoreController> {
  const StoreEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StoreModel? editing = Get.arguments as StoreModel?;
    if (editing != null) {
      controller.nameController.text = editing.name;
      controller.descriptionController.text = editing.description;
    }
    final SwapController swap = Get.put(SwapController());
    return Scaffold(
      appBar: AppBar(
        title: Text(editing == null ? 'Crear tienda' : 'Editar tienda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview del banner con selección desde galería
            Obx(() {
              final File? banner = controller.bannerImage.value;
              return GestureDetector(
                onTap: controller.pickBannerFromGallery,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: banner != null
                          ? Image.file(banner, fit: BoxFit.cover)
                          : (editing?.bannerUrl.isNotEmpty == true
                                ? Image.network(
                                    editing!.bannerUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.image_rounded,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Toca para seleccionar banner',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  )),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Logo con selección desde galería
            Obx(() {
              final File? logo = controller.logoImage.value;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: logo != null
                        ? FileImage(logo)
                        : (editing?.logoUrl.isNotEmpty == true
                              ? NetworkImage(editing!.logoUrl) as ImageProvider
                              : null),
                    child: (logo == null && (editing?.logoUrl.isEmpty ?? true))
                        ? const Icon(Icons.storefront_rounded)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: controller.pickLogoFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text('Cambiar logo'),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Text(
              'Artículos de mi tienda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<SwapItemModel>>(
              stream: swap.getUserSwaps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final List<SwapItemModel> items =
                    snapshot.data ?? <SwapItemModel>[];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Aún no tienes artículos. Agrega uno para que aparezca en tu tienda.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final SwapItemModel item = items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '\$${item.estimatedPrice.toStringAsFixed(0)} • ${item.size} • ${item.condition}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String v) async {
                            if (v == 'edit') {
                              swap.startEditing(item);
                              await Get.toNamed(Routes.createSwap);
                            } else if (v == 'delete') {
                              await swap.deleteSwap(item);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              const <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(Routes.createSwap),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar artículo'),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  return Expanded(
                    child: FilledButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.createOrUpdateStore(
                              storeId: editing?.id,
                            ),
                      child: Text(
                        editing == null ? 'Crear tienda' : 'Guardar cambios',
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
