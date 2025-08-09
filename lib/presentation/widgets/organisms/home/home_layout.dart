import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/home/home_controller.dart';
import '../../../../controllers/auth/auth_controller.dart';

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
                      ? const SafeArea(child: _ProfileView())
                      : PageView(
                          controller: controller.pageController,
                          onPageChanged: controller.handlePageChanged,
                          children: const [
                            _HomePlaceholder(),
                            _StorePlaceholder(),
                            _SwapsPlaceholder(),
                            _MessagesPlaceholder(),
                            _ProfileView(),
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
              child: _BottomNavBar(
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

class _BottomNavBar extends StatelessWidget {
  final HomeController controller;
  final ColorScheme colorScheme;
  const _BottomNavBar({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                _NavItem(
                  index: 1,
                  icon: Icons.storefront_rounded,
                  label: 'Store',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                _CenterAction(
                  onPressed: () => controller.changeIndex(2),
                  isActive: controller.currentIndex.value == 2,
                  colorScheme: colorScheme,
                ),
                _NavItem(
                  index: 3,
                  icon: Icons.chat_bubble_rounded,
                  label: 'Messages',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                _NavItem(
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final HomeController controller;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.controller,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = controller.currentIndex.value == index;
    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final ColorScheme colorScheme;

  const _CenterAction({
    required this.onPressed,
    required this.isActive,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 36,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.sync_alt_rounded,
          color: isActive ? colorScheme.onPrimary : colorScheme.onSecondary,
        ),
      ),
    );
  }
}

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

class _ProfileView extends GetView<AuthController> {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Obx(() {
      final String name = controller.userName.value;
      final String email = controller.userEmail.value;

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
                    child: Obx(() {
                      final String? url = controller.profileImage.value;
                      return CircleAvatar(
                        radius: 44,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.18,
                        ),
                        backgroundImage: (url != null && url.isNotEmpty)
                            ? NetworkImage(url)
                            : null,
                        child: (url == null || url.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                color: colorScheme.primary,
                                size: 40,
                              )
                            : null,
                      );
                    }),
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
                    onPressed: () {
                      Get.toNamed("/edit-profile");
                    },
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
                  _SectionTitle(title: 'Inventories'),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        leadingIcon: Icons.home_outlined,
                        title: 'My stores',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CountPill(value: 2),
                            const SizedBox(width: 10),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        leadingIcon: Icons.support_agent_outlined,
                        title: 'Support',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(title: 'Preferences'),
                  _SettingsCard(
                    children: [
                      _SettingsSwitchTile(
                        leadingIcon: Icons.notifications_outlined,
                        title: 'Push notifications',
                        value: controller.isAppLockEnabled.value,
                        onChanged: (bool v) => controller.toggleAppLock(v),
                      ),
                      const Divider(height: 1),
                      _SettingsSwitchTile(
                        leadingIcon: Icons.face_retouching_natural_rounded,
                        title: 'Face ID',
                        value: controller.isBiometricEnabled.value,
                        onChanged: (bool v) => controller.toggleBiometric(v),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        leadingIcon: Icons.pin_rounded,
                        title: 'PIN Code',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.leadingIcon,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leadingIcon, color: colorScheme.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: titleColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.leadingIcon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      leadingIcon: leadingIcon,
      title: title,
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int value;
  const _CountPill({required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
