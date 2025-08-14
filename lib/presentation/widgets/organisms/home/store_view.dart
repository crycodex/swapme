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
          SliverAppBar(
            pinned: true,
            backgroundColor: color.surface,
            title: const Text('Store'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search stores',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StreamBuilder<StoreModel?>(
                    stream: controller.getMyStore(),
                    builder: (context, snapshot) {
                      final bool hasStore = snapshot.data != null;
                      return IconButton(
                        onPressed: hasStore
                            ? () => Get.toNamed(
                                Routes.storeDetail,
                                arguments: snapshot.data,
                              )
                            : () => Get.toNamed(Routes.storeEditor),
                        style: IconButton.styleFrom(
                          backgroundColor: color.primary,
                          foregroundColor: color.onPrimary,
                        ),
                        icon: Icon(
                          hasStore
                              ? Icons.storefront_rounded
                              : Icons.add_business_rounded,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<StoreModel>>(
              stream: controller.getStores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final List<StoreModel> stores = snapshot.data ?? <StoreModel>[];
                if (stores.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aún no hay tiendas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: stores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final StoreModel s = stores[index];
                    return _StoreTile(store: s, theme: theme, color: color);
                  },
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  final StoreModel store;
  final ThemeData theme;
  final ColorScheme color;
  const _StoreTile({
    required this.store,
    required this.theme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.toNamed(Routes.storeDetail, arguments: store),
      child: Container(
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
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
              ),
              title: Text(
                store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                store.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(store.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Items: ${store.itemsCount}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
