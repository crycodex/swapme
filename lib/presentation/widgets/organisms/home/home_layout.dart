import 'package:flutter/material.dart';
import '../profile/profile_view.dart';
import '../../molecules/swaps_section.dart';
import '../../molecules/header_carousel.dart';
import '../../../../routes/routes.dart';
import '../../../../data/models/swap_item_model.dart';
import 'bottom_nav.dart';
import 'store_view.dart';
import 'messages_view.dart';
import '../../atoms/ad_banner_widget.dart';
//controllers
import 'package:get/get.dart';
import '../../../../controllers/home/home_controller.dart';

class HomeLayout extends GetView<HomeController> {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MediaQueryData media = MediaQuery.of(context);

    return Obx(() {
      final int currentIndex = controller.currentIndex.value;
      final bool isFullScreenView =
          currentIndex >= 3; // Messages (3) y Profile (4)

      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            isFullScreenView
                ? _buildFullScreenView(currentIndex)
                : NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        backgroundColor: colorScheme.surface,
                        expandedHeight: media.size.height * 0.26,
                        floating: false,
                        pinned: true,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: false,
                          expandedTitleScale: 1.4,
                          titlePadding: const EdgeInsetsDirectional.only(
                            start: 16,
                            bottom: 12,
                          ),
                          title: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'SwapMe',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          background: HeaderCarousel(colorScheme: colorScheme),
                        ),
                      ),
                    ],
                    body: PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.handlePageChanged,
                      children: [
                        _HomePlaceholder(controller: controller),
                        const StoreView(),
                      ],
                    ),
                  ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Banner de anuncio
                    const BottomAdBannerWidget(),
                    // Bottom Navigation Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: BottomNavBar(
                        controller: controller,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFullScreenView(int index) {
    switch (index) {
      case 3:
        return const SafeArea(child: MessagesView());
      case 4:
        return const SafeArea(child: ProfileView());
      default:
        return const SizedBox.shrink();
    }
  }
}

// Placeholders
class _HomePlaceholder extends StatelessWidget {
  final HomeController controller;
  const _HomePlaceholder({required this.controller});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return NotificationListener<UserScrollNotification>(
      onNotification: (UserScrollNotification n) {
        // futuro: colapsar header con animaciones si se requiere
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(height: 20, color: Colors.transparent),
          ),
          // Buscador
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: controller.updateSearch,
                decoration: InputDecoration(
                  hintText: 'Buscar prendas',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Filtros de categoría
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: Obx(() {
                final String selectedCategory =
                    controller.selectedCategory.value;
                final List<String> categories = controller.categories;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final String cat = categories[index];
                    final bool isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => controller.selectCategory(cat),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: categories.length,
                );
              }),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          // Catálogo global (todos menos mis swaps)
          SliverToBoxAdapter(
            child: SwapsSection(
              controller: controller,
              streamOverride: controller.allSwaps,
              maxItems: 15,
              onSeeAll: () => Get.to(() => const _ExploreMorePage()),
              onItemTap: (SwapItemModel item) {
                Get.toNamed(Routes.swapDetail, arguments: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// removed Store placeholder; real StoreView is used

// Messages placeholder removed - now uses full screen MessagesView

class _ExploreMorePage extends GetView<HomeController> {
  const _ExploreMorePage();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Buscar prendas',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filtros
          SizedBox(
            height: 40,
            child: Obx(() {
              final String selected = controller.selectedCategory.value;
              final List<String> categories = controller.categories;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String cat = categories[index];
                  final bool isSelected = selected == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => controller.selectCategory(cat),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          // Grid con paginación simple por lotes
          Expanded(child: _ExploreGrid(color: color)),
        ],
      ),
    );
  }
}

class _ExploreGrid extends StatefulWidget {
  final ColorScheme color;
  const _ExploreGrid({required this.color});

  @override
  State<_ExploreGrid> createState() => _ExploreGridState();
}

class _ExploreGridState extends State<_ExploreGrid> {
  static const int pageSize = 24;
  int _loaded = pageSize;

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.put(HomeController());
    return Obx(() {
      // trigger rebuild on filters
      home.searchQuery.value;
      home.selectedCategory.value;
      return StreamBuilder<List<SwapItemModel>>(
        stream: home.allSwaps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<SwapItemModel> items = home.filterSwaps(
            snapshot.data ?? <SwapItemModel>[],
          );
          if (items.isEmpty) {
            return const Center(child: Text('No hay resultados'));
          }
          items = items.take(_loaded).toList();
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
                setState(() => _loaded += pageSize);
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.76,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final SwapItemModel item = items[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(Routes.swapDetail, arguments: item),
                  child: ClipRRect(
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
                              color: widget.color.surface.withValues(
                                alpha: 0.9,
                              ),
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: 14,
                                      color: widget.color.primary,
                                    ),
                                    Text(
                                      item.estimatedPrice.toStringAsFixed(0),
                                      style: TextStyle(
                                        color: widget.color.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
}
