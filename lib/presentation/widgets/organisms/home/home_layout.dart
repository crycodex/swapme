import 'package:flutter/material.dart';
import 'dart:async';
import '../profile/profile_view.dart';
import '../../molecules/swaps_section.dart';
import '../../../../routes/routes.dart';
import '../../../../data/models/swap_item_model.dart';
import 'bottom_nav.dart';
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
      final bool isProfile = controller.currentIndex.value == 4;
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            isProfile
                ? const SafeArea(child: ProfileView())
                : NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        backgroundColor: colorScheme.surface,
                        expandedHeight: media.size.height * 0.26,
                        floating: false,
                        pinned: true,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _HeaderHeroCarousel(
                            theme: theme,
                            colorScheme: colorScheme,
                            media: media,
                          ),
                        ),
                      ),
                    ],
                    body: PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.handlePageChanged,
                      children: [
                        _HomePlaceholder(controller: controller),
                        const _StorePlaceholder(),
                        const _SwapsPlaceholder(),
                        const _MessagesPlaceholder(),
                        const ProfileView(),
                      ],
                    ),
                  ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + media.padding.bottom,
              child: BottomNavBar(
                controller: controller,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      );
    });
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

class _StorePlaceholder extends StatelessWidget {
  const _StorePlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Store'));
  }
}

class _SwapsPlaceholder extends StatelessWidget {
  const _SwapsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Swaps'));
  }
}

class _MessagesPlaceholder extends StatelessWidget {
  const _MessagesPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Messages'));
  }
}

class _HeaderCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  const _HeaderCard({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SwapMe',
              style: theme.textTheme.displaySmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}

class _HeaderHeroCarousel extends StatefulWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final MediaQueryData media;
  const _HeaderHeroCarousel({
    required this.theme,
    required this.colorScheme,
    required this.media,
  });

  @override
  State<_HeaderHeroCarousel> createState() => _HeaderHeroCarouselState();
}

class _HeaderHeroCarouselState extends State<_HeaderHeroCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _index = (_index + 1) % 3;
      _pageController.animateToPage(
        _index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = widget.theme;
    final ColorScheme colorScheme = widget.colorScheme;
    final MediaQueryData media = widget.media;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: 3,
          itemBuilder: (_, int i) {
            return Container(
              margin: EdgeInsets.only(left: 1, right: 1, bottom: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
        // Overlay con el saludo y tokens en la misma posición
        Padding(
          padding: EdgeInsets.only(
            top: media.padding.top + 16,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          child: _HeaderCard(theme: theme, colorScheme: colorScheme),
        ),
        // Indicadores
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (int i) {
              final bool active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: active ? 0.9 : 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
