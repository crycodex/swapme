import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../atoms/section_title.dart';
import '../../molecules/settings_card.dart';
import '../../molecules/settings_tile.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/home/home_controller.dart';
import '../../../../controllers/limits/user_limits_controller.dart';
import '../../molecules/swaps_section.dart';
import '../../../../controllers/swap/swap_controller.dart';
import '../../../../controllers/store/store_controller.dart';
import '../../../../controllers/swap/swap_history_controller.dart';
import '../../../../data/models/store_model.dart';
import '../../../../data/models/swap_item_model.dart';
import '../../atoms/ad_banner_widget.dart';
import '../../atoms/rating_stars.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Obx(() {
      final String name = controller.userName.value;
      final String email = controller.userEmail.value;
      final bool isDark = controller.isDarkMode.value;

      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colorScheme.surface,
              title: const Text('Perfil'),
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => controller.pickAndUploadProfileImage(),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.18,
                        ),
                        backgroundImage:
                            (controller.profileImage.value != null &&
                                controller.profileImage.value!.isNotEmpty)
                            ? NetworkImage(controller.profileImage.value!)
                            : null,
                        child:
                            (controller.profileImage.value == null ||
                                controller.profileImage.value!.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                color: colorScheme.primary,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name.isEmpty ? 'Usuario' : name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mostrar calificaciones y estadísticas del usuario
                    GetBuilder<SwapHistoryController>(
                      init: Get.put(SwapHistoryController()),
                      builder: (SwapHistoryController historyController) {
                        return Obx(() {
                          final userStats = historyController.userStats.value;
                          if (userStats != null && userStats.totalRatings > 0) {
                            return GestureDetector(
                              onTap: () => Get.toNamed(
                                '/user-ratings',
                                arguments: {
                                  'userId': controller.uid.value,
                                  'userName': name.isEmpty ? 'Usuario' : name,
                                },
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RatingStars(
                                      rating: userStats.averageRating,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${userStats.averageRating.toStringAsFixed(1)} (${userStats.totalRatings})',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 14,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => Get.toNamed('/edit-profile'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Editar perfil'),
                    ),
                    const SizedBox(height: 22),
                    const SectionTitle(title: 'Preferencias'),
                    SettingsCard(
                      children: [
                        // Permisos de mi tienda hidden
                        /*  GetBuilder<UserLimitsController>(
                          init: Get.put(UserLimitsController()),
                          builder: (UserLimitsController limitsController) {
                            final bool canCreateStore = limitsController
                                .canUserCreateStore();

                            return SettingsTile(
                              leadingIcon: canCreateStore
                                  ? Icons.storefront_rounded
                                  : Icons.lock,
                              title: canCreateStore
                                  ? 'Mi tienda'
                                  : 'Mi tienda (Premium)',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!canCreateStore)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Premium',
                                        style: TextStyle(
                                          color: Colors.amber[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    canCreateStore
                                        ? Icons.chevron_right_rounded
                                        : Icons.lock,
                                    color: canCreateStore ? null : Colors.grey,
                                  ),
                                ],
                              ),
                              onTap: canCreateStore
                                  ? () async {
                                      final StoreController store = Get.put(
                                        StoreController(),
                                      );
                                      final StoreModel? mine = await store
                                          .getMyStoreOnce();
                                      if (mine == null) {
                                        Get.toNamed('/store-editor');
                                      } else {
                                        Get.toNamed(
                                          '/store-detail',
                                          arguments: mine,
                                        );
                                      }
                                    }
                                  : () => _showPremiumRequiredDialog(context),
                            );
                          },
                        ), */
                        const Divider(height: 1),
                        SettingsTile(
                          leadingIcon: Icons.history,
                          title: 'Historial de intercambios',
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Get.toNamed('/swap-history'),
                        ),
                        const Divider(height: 1),
                        SettingsSwitchTile(
                          leadingIcon: Icons.dark_mode_outlined,
                          title: 'Modo oscuro',
                          value: isDark,
                          onChanged: (_) => controller.toggleTheme(),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          leadingIcon: Icons.language_outlined,
                          title: 'Licencias',
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Get.toNamed(
                            '/licenses',
                            arguments: {'context': context},
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          leadingIcon: Icons.logout_rounded,
                          title: 'Cerrar sesión',
                          titleColor: colorScheme.error,
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Banner de anuncio en perfil
                    const ProfileAdBannerWidget(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            // Mis swaps del usuario en perfil
            SliverToBoxAdapter(
              child: GetBuilder<HomeController>(
                init: Get.put(HomeController()),
                builder: (HomeController home) {
                  return SwapsSection(
                    controller: home,
                    onSeeAll: () => Get.to(() => const _MySwapsPage()),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      );
    });
  }

  void _confirmLogout(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showPremiumRequiredDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            const Text('Función Premium'),
          ],
        ),
        content: const Text(
          'Para crear una tienda necesitas una cuenta Premium. '
          'Los usuarios gratuitos tienen acceso limitado a 3 swaps por mes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: color.secondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              // Aquí puedes navegar a la pantalla de upgrade premium
              Get.snackbar(
                'Actualizar a Premium',
                'Función en desarrollo',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.amber,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Actualizar a Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MySwapsPage extends GetView<SwapController> {
  const _MySwapsPage();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis artículos')),
      body: StreamBuilder<List<SwapItemModel>>(
        stream: controller.getUserSwaps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<SwapItemModel> items = snapshot.data ?? <SwapItemModel>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Aún no tienes artículos intercambiados',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final SwapItemModel item = items[index];
              return _MySwapTile(item: item, color: color, theme: theme);
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => Get.toNamed('/create-swap'),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo artículo'),
          ),
        ),
      ),
    );
  }
}

class _MySwapTile extends GetView<SwapController> {
  final SwapItemModel item;
  final ColorScheme color;
  final ThemeData theme;
  const _MySwapTile({
    required this.item,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '\$${item.estimatedPrice.toStringAsFixed(0)} • ${item.size} • ${item.condition}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) async {
            if (value == 'edit') {
              controller.startEditing(item);
              await Get.toNamed('/create-swap');
            } else if (value == 'delete') {
              await controller.deleteSwap(item);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Eliminar'),
            ),
          ],
        ),
        onTap: () => Get.toNamed('/swap-detail', arguments: item),
      ),
    );
  }
}
