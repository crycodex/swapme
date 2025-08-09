import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/home/home_controller.dart';
// auth controller not needed here after splitting profile view
import '../profile/profile_view.dart';
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
      final double headerHeight = isProfile ? 0 : media.size.height * 0.35;
      final double contentTop = isProfile ? 0 : media.size.height * 0.18;
      return Scaffold(
        backgroundColor: isProfile
            ? colorScheme.surface
            : colorScheme.secondary.withValues(alpha: 0.5),
        body: Stack(
          children: [
            if (!isProfile)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: headerHeight,
                    color: colorScheme.primary,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: media.padding.top + 8,
                        left: 20,
                        right: 20,
                        bottom: 16,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'SwapMe',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Contenido scrollable
            Positioned.fill(
              top: contentTop,
              child: ClipRRect(
                borderRadius: isProfile
                    ? BorderRadius.zero
                    : const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                child: Container(
                  color: colorScheme.surface,
                  child: isProfile
                      ? const SafeArea(child: ProfileView())
                      : PageView(
                          controller: controller.pageController,
                          onPageChanged: controller.handlePageChanged,
                          children: const [
                            _HomePlaceholder(),
                            _StorePlaceholder(),
                            _SwapsPlaceholder(),
                            _MessagesPlaceholder(),
                            ProfileView(),
                          ],
                        ),
                ),
              ),
            ),

            // Nav bar flotante con efecto glass
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

// Bottom nav and aux classes moved to organisms/home/bottom_nav.dart

// Placeholders
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(height: 320, color: Colors.transparent),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 600,
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
            ),
          ),
        ),
      ],
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

// ProfileView moved to organisms/profile/profile_view.dart

// Settings helpers moved to molecules/widgets
