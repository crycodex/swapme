import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/home/home_controller.dart';
import '../profile/profile_view.dart';
import '../../molecules/swaps_section.dart';
import '../../../../routes/routes.dart';
import '../../../../data/models/swap_item_model.dart';
import '../../../../controllers/auth/auth_controller.dart';
import 'bottom_nav.dart';

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
        body: isProfile
            ? const SafeArea(child: ProfileView())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    backgroundColor: colorScheme.primary,
                    expandedHeight: media.size.height * 0.26,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.only(
                          top: media.padding.top + 8,
                          left: 20,
                          right: 20,
                          bottom: 16,
                        ),
                        child: _HeaderCard(
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                      ),
                    ),
                  ),
                ],
                body: Stack(
                  children: [
                    PageView(
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
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
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Explorar Swaps',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Próximamente...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class _HeaderCard extends GetView<AuthController> {
  final ThemeData theme;
  final ColorScheme colorScheme;
  const _HeaderCard({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String username = controller.userName.value.isEmpty
          ? 'Usuario'
          : controller.userName.value;
      final int coins = controller.tokens.value;
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.waving_hand_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Bienvenido $username',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.token_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 6),
                Text(
                  coins.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
