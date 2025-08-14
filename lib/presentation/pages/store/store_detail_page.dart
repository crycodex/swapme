import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/store/store_controller.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_item_model.dart';
import '../../../routes/routes.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../../../data/models/swap_item_model.dart';

class StoreDetailPage extends GetView<StoreController> {
  const StoreDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    final StoreModel store = Get.arguments as StoreModel;
    final bool mine = controller.isOwner(store);

    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
        actions: [
          if (mine)
            PopupMenuButton<String>(
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
                    PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: store.bannerUrl.isEmpty
                        ? Container(color: color.surfaceContainerHighest)
                        : Image.network(store.bannerUrl, fit: BoxFit.cover),
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: store.logoUrl.isEmpty
                        ? null
                        : NetworkImage(store.logoUrl),
                    radius: 22,
                  ),
                  title: Text(
                    store.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(store.description),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Text(
                    'Items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<StoreItemModel>>(
              stream: controller.getItemsByStore(store.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final List<StoreItemModel> items =
                    snapshot.data ?? <StoreItemModel>[];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('No hay artículos')),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final StoreItemModel item = items[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.surface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: color.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (mine)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: PopupMenuButton<String>(
                                onSelected: (String v) async {
                                  if (v == 'edit') {
                                    controller.startEditingStoreItem(item);
                                    Get.toNamed(
                                      Routes.createStoreItem,
                                      arguments: <String, dynamic>{
                                        'store': store,
                                        'item': item,
                                      },
                                    );
                                  } else if (v == 'delete') {
                                    await controller.deleteStoreItem(
                                      store.id,
                                      item,
                                    );
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
                        ],
                      ),
                    );
                  },
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
