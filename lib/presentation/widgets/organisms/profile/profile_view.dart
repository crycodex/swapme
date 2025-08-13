import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../atoms/section_title.dart';
import '../../molecules/settings_card.dart';
import '../../molecules/settings_tile.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/home/home_controller.dart';
import '../../molecules/swaps_section.dart';

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

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).size.height * 0.14),
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
                    child: const Text('Edit profile'),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Preferences'),
                  SettingsCard(
                    children: [
                      SettingsSwitchTile(
                        leadingIcon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        value: isDark,
                        onChanged: (_) => controller.toggleTheme(),
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        leadingIcon: Icons.logout_rounded,
                        title: 'Logout',
                        titleColor: colorScheme.error,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          // Mis swaps del usuario en perfil
          SliverToBoxAdapter(
            child: GetBuilder<HomeController>(
              init: Get.find<HomeController>(),
              builder: (HomeController home) {
                return SwapsSection(controller: home);
              },
            ),
          ),
        ],
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
}
